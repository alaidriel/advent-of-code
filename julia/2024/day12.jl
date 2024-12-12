include("../common/utils.jl")

directions = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)])
diagonals = CartesianIndex.([(-1, 1), (-1, -1), (1, 1), (1, -1)])
pairs = [
    CartesianIndex.((-1, 0), (0, 1)),
    CartesianIndex.((-1, 0), (0, -1)),
    CartesianIndex.((1, 0), (0, 1)),
    CartesianIndex.((1, 0), (0, -1))
]

findRegions = garden -> begin
    visited, regions = Set(), []
    for start in CartesianIndices(garden)
        if !(start in visited)
            S, kind, region = [], garden[start], Set()
            push!(S, start)
            while !isempty(S)
                current = pop!(S)
                if !(current in region)
                    push!(region, current)
                    for direction in directions
                        next = current + direction
                        checkbounds(Bool, garden, next) && garden[next] == kind && push!(S, next)
                    end
                end
            end
            push!(visited, region...)
            push!(regions, (kind, region))
        end
    end
    regions
end

edge = (garden, kind, point; ensureInBounds=false) -> begin
    inbounds = checkbounds(Bool, garden, point)
    inbounds && garden[point] != kind || (ensureInBounds ? false : !inbounds)
end

perimeter = (garden, kind, region) -> sum(map(plot -> length(collect(
        filter(direction -> edge(garden, kind, plot + direction), directions))),
    collect(region)))

sides = (garden, kind, region) -> sum(map(plot ->
        length(collect(filter(pair -> edge(garden, kind, plot + pair[1]) && edge(garden, kind, plot + pair[2]),
            pairs))) + length(collect(filter(direction ->
                all(o -> checkbounds(Bool, garden, plot + o) && garden[plot+o] == kind,
                    CartesianIndex.([(direction[1], 0), (0, direction[2])])) &&
                    edge(garden, kind, plot + direction, ensureInBounds=true), diagonals))), collect(region)))

price = (input; scorer = perimeter) -> begin
    garden = stack(split.(split(input, "\n"), ""), dims=1)
    regions = findRegions(garden)
    sum(map(region -> scorer(garden, region[1], region[2]) * length(region[2]), regions))
end

partOne = input -> price(input)

partTwo = input -> price(input, scorer=sides)

common.test(2024, 12,
    partOne,
    partTwo,
    distinct=false,
    expected=(1488414, 911750),
    testExpected=(1930, 1206)
)
