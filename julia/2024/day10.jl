include("../common/utils.jl")

traverseMap = (destination, map, scores, redundant) -> begin
    stack, visited, paths = [], Set(), 0
    push!(stack, destination)
    while length(stack) > 0
        current = pop!(stack)
        current ∈ visited && !redundant && continue
        push!(visited, current)
        if map[current] == 0
            get!(scores, current, 0)
            scores[current] += 1
        end
        for adjacent in CartesianIndex.([(0, 1), (1, 0), (-1, 0), (0, -1)])
            next = current + adjacent
            if checkbounds(Bool, map, next) && map[next] - map[current] == -1
                push!(stack, next)
            end
        end
    end
end

solveWith = (input; redundant = false) -> begin
    map, scores = parse.(Int, stack(split.(split(input, "\n"), ""), dims=1)), Dict()
    foreach(destination -> traverseMap(destination, map, scores, redundant),
        filter(index -> map[index] == 9, CartesianIndices(map)))
    return sum(values(scores))
end

partOne = input -> solveWith(input)

partTwo = input -> solveWith(input, redundant=true)

common.test(2024, 10,
    partOne,
    partTwo,
    distinct=false,
    expected=(667, 1344),
    testExpected=(36, 81)
)
