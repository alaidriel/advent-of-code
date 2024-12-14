include("../common/utils.jl")

using DataStructures

findComponents = grid -> begin
    directions = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)])
    visited, regions = Set(), []
    for start in CartesianIndices(grid)
        if grid[start] == 1.0 && !(start in visited)
            S, kind, region = [], grid[start], Set()
            push!(S, start)
            while !isempty(S)
                current = pop!(S)
                if !(current in region)
                    push!(region, current)
                    for direction in directions
                        next = current + direction
                        checkbounds(Bool, grid, next) && grid[next] == 1.0 && push!(S, next)
                    end
                end
            end
            push!(visited, region...)
            push!(regions, length(region))
        end
    end
    regions
end

partOne = input -> begin
    behavior = transpose(reshape(
        stack(parse.(Int, map(m -> m.match, eachmatch.(r"-?\d+", input))), dims=1),
        (4, :)))
    cols, rows = length(split(input, "\n")) == 12 ? (11, 7) : (101, 103)
    quadrants = [
        [(0, div(cols, 2) - 1), (0, div(rows, 2) - 1)],
        [(div(cols, 2) + 1, cols - 1), (0, div(rows, 2) - 1)],
        [(0, div(cols, 2) - 1), (div(rows, 2) + 1, rows - 1)],
        [(div(cols, 2) + 1, cols - 1), (div(rows, 2) + 1, rows - 1)],
    ]
    locations, robots = DefaultDict(0), DefaultDict(0)
    for (px, py, vx, vy) in eachrow(behavior)
        x = mod(px + 100 * vx, cols)
        y = mod(py + 100 * vy, rows)
        locations[(x, y)] += 1
    end
    for location in keys(locations)
        for quadrant in quadrants
            (x, y), (qx, qy) = location, quadrant
            if qx[1] <= x <= qx[2] && qy[1] <= y <= qy[2]
                robots[quadrant] += locations[location]
            end
        end
    end
    prod(values(robots))
end

partTwo = input -> begin
    data = transpose(reshape(
        stack(parse.(Int, map(m -> m.match, eachmatch.(r"-?\d+", input))), dims=1),
        (4, :)))
    cols, rows = length(split(input, "\n")) == 12 ? (11, 7) : (101, 103)
    # see if we can find a cycle in the robot behavior
    # if we do, then I'll assume there are finitely many states that repeat
    findCycle = (f, x0) -> begin
        tortoise = x0 + 1
        hare = x0 + 2
        while f(tortoise) != f(hare)
            @assert tortoise * 2 == hare
            tortoise += 1
            hare += 2
        end
        @assert tortoise == hare - tortoise
        hare - tortoise
    end
    gridFor = times -> begin
        grid = zeros(cols, rows)
        for (px, py, vx, vy) in eachrow(data)
            x = mod(px + times * vx, cols)
            y = mod(py + times * vy, rows)
            grid[CartesianIndex(x + 1, y + 1)] += 1
        end
        grid
    end
    toCheck = findCycle(gridFor, 0) # we have to check at most this many states
    # to determine the state with the christmas tree, see which state's largest connected component is largest
    # among all states (assumption that the tree picture will be one or two relatively large connected components)
    foldl((cur, times) -> maximum(findComponents(gridFor(times))) > cur ? times : cur,
        # TODO: cycle starts at exactly 1? iterating over [1, toCheck] yields all possible states
        range(1, toCheck), init=0)
end

common.test(2024, 14,
    partOne,
    partTwo,
    distinct=false,
    expected=(230461440, 6668),
    testExpected=(12, 6) # 6 means nothing
)
