include("../common/utils.jl")

attributes = input -> (
    length(split(input, "\n")) == 25 ? (7, 7) : (71, 71),
    length(split(input, "\n")) == 25 ? 12 : 1024)

coordinates = input -> reverse.(collect(Iterators.partition(
    parse.(Int, map(m -> m.match, eachmatch(r"\d+", input))), 2)))

fill = (bytes, simulate, memory) -> begin
    for (y, x) in Iterators.take(bytes, simulate)
        memory[CartesianIndex(y + 1, x + 1)] = 1
    end
end

wayToEnd = (memory, shape) -> begin
    Q, visited = [(0, CartesianIndex(1, 1))], Set()
    while !isempty(Q)
        (depth, current) = popfirst!(Q)
        current == CartesianIndex(shape) && return depth
        if current ∉ visited
            push!(visited, current)
            for direction in CartesianIndex.([(0, 1), (0, -1), (-1, 0), (1, 0)])
                next = current + direction
                checkbounds(Bool, memory, next) && memory[next] == 0 && push!(Q, (depth + 1, next))
            end
        end
    end
end

partOne = input -> begin
    shape, simulate = attributes(input)
    memory, bytes = zeros(shape), coordinates(input)
    fill(bytes, simulate, memory)
    wayToEnd(memory, shape)
end

partTwo = input -> begin
    (shape, simulate), bytes = attributes(input), coordinates(input)
    for simulate in range(simulate, length(bytes))
        memory = zeros(shape)
        fill(bytes, simulate, memory)
        isnothing(wayToEnd(memory, shape)) && return join(reverse(bytes[simulate]), ",")
    end
end

common.test(2024, 18,
    partOne,
    partTwo,
    distinct=false,
    expected=(262, "22,20"),
    testExpected=(22, "6,1")
)
