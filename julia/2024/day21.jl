include("../common/utils.jl")

directions = Dict(1 => "^", 2 => ">", 3 => "v", 4 => "<")

numerical = Dict(
    "0" => ["2", "A", nothing, nothing],
    "1" => ["4", "2", nothing, nothing],
    "2" => ["5", "3", "0", "1"],
    "3" => ["6", nothing, "A", "2"],
    "4" => ["7", "5", "1", nothing],
    "5" => ["8", "6", "2", "4"],
    "6" => ["9", nothing, "3", "5"],
    "7" => [nothing, "8", "4", nothing],
    "8" => [nothing, "9", "5", "7"],
    "9" => [nothing, nothing, "6", "8"],
    "A" => ["3", nothing, nothing, "0"]
)

directional = Dict(
    "A" => [nothing, nothing, ">", "^"],
    "^" => [nothing, "A", "v", nothing],
    "<" => [nothing, "v", nothing, nothing],
    "v" => ["^", ">", nothing, "<"],
    ">" => ["A", nothing, nothing, "v"]
)

movements = (keypad, start, goal) -> begin
    Q, visited, paths, cutoff = [(start, 0, [])], Set(), [], nothing
    while !isempty(Q)
        current, depth, path = popfirst!(Q)
        !isnothing(cutoff) && depth > cutoff && break
        if current == goal
            cutoff = depth
            push!(paths, [path; "A"])
        end
        if !in(current, visited)
            for (index, key) in Iterators.filter(pair -> !isnothing(pair[2]), enumerate(keypad[current]))
                push!(Q, (key, depth + 1, [path; directions[index]]))
            end
        end
    end
    paths
end

groups = moveset -> length(collect(eachmatch(r"(\^+)|(<+)+|(>+)+|(v+)", join(moveset))))

sequence = (code, keypad) -> begin
    code, paths = split(code, ""), []
    Q, visited = [("A", 1, [])], Set()
    while !isempty(Q)
        current, keyIndex, path = popfirst!(Q)
        if keyIndex > length(code)
            push!(paths, join(path))
            continue
        end
        if !in((current, path), visited)
            push!(visited, (current, path))
            key = code[keyIndex]
            moves = movements(keypad, current, key)
            minGroups = Iterators.minimum(groups, moves)
            for moveset in filter(moveset -> groups(moveset) == minGroups, moves)
                push!(Q, (key, keyIndex + 1, [path; moveset]))
            end
        end
    end
    paths
end

solveWith = (input; N = 2) -> begin
    sum(map(code -> begin
            n = parse(Int, match(r"\d+", code).match)
            sequences = foldl((sequences, d) -> Iterators.flatmap(seq -> sequence(seq, directional), sequences),
                range(1, N), init=sequence(code, numerical))
            len = Iterators.minimum(Iterators.map(seq -> length(seq), sequences))
            len * n
        end, split(input, "\n")))
end

partOne = input -> solveWith(input)

partTwo = input -> begin end

common.test(2024, 21,
    partOne,
    partTwo,
    distinct=false,
    expected=(242484, nothing),
    testExpected=(126384, nothing)
)
