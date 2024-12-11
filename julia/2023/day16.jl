# this is incredibly ugly but i am way too lazy to try to make this cleaner
include("../common/utils.jl")

offsetFor = Dict(
    ">" => CartesianIndex(0, 1),
    "v" => CartesianIndex(1, 0),
    "<" => CartesianIndex(0, -1),
    "^" => CartesianIndex(-1, 0)
)

function countEnergized(grid, light)
    energized = fill(".", size(grid))
    visited = Set()
    while !isempty(light)
        direction, point = popfirst!(light)
        (direction, point) in visited && continue
        if checkbounds(Bool, grid, point)
            push!(visited, (direction, point))
            current = grid[point]
            energized[point] = "#"
            if current == "|"
                if (direction == ">" || direction == "<")
                    push!(light, ("^", point + offsetFor["^"]))
                    push!(light, ("v", point + offsetFor["v"]))
                else
                    push!(light, (direction, point + offsetFor[direction]))
                end
            elseif current == "-"
                if (direction == "v" || direction == "^")
                    push!(light, ("<", point + offsetFor["<"]))
                    push!(light, (">", point + offsetFor[">"]))
                else
                    push!(light, (direction, point + offsetFor[direction]))
                end
            elseif current == "/"
                if direction == ">"
                    push!(light, ("^", point + offsetFor["^"]))
                elseif direction == "<"
                    push!(light, ("v", point + offsetFor["v"]))
                elseif direction == "^"
                    push!(light, (">", point + offsetFor[">"]))
                else
                    push!(light, ("<", point + offsetFor["<"]))
                end
            elseif current == "\\"
                if direction == ">"
                    push!(light, ("v", point + offsetFor["v"]))
                elseif direction == "<"
                    push!(light, ("^", point + offsetFor["^"]))
                elseif direction == "^"
                    push!(light, ("<", point + offsetFor["<"]))
                else
                    push!(light, (">", point + offsetFor[">"]))
                end
            elseif current == "."
                push!(light, (direction, point + offsetFor[direction]))
            end
        end
    end
    return length(filter(tile -> tile === "#", energized))
end

function partOne(input)
    grid = stack(split.(split(input, "\n"), ""), dims=1)
    return countEnergized(grid, [(">", CartesianIndex(1, 1))])
end

function partTwo(input)
    grid = stack(split.(split(input, "\n"), ""), dims=1)
    rows, cols = size(grid)
    starts = collect(filter(
        index -> index[1] == 1 || index[2] == 1 || index[1] == rows || index[2] == cols,
        CartesianIndices(grid)))
    best = 0
    for start in starts
        if start[1] == 1 && start[2] == 1
            best = max(best, countEnergized(grid, [(">", start)]))
            best = max(best, countEnergized(grid, [("v", start)]))
        elseif start[1] == 1 && start[2] == cols
            best = max(best, countEnergized(grid, [("<", start)]))
            best = max(best, countEnergized(grid, [("v", start)]))
        elseif start[1] == rows && start[2] == 1
            best = max(best, countEnergized(grid, [("^", start)]))
            best = max(best, countEnergized(grid, [(">", start)]))
        elseif start[1] == rows && start[2] == cols
            best = max(best, countEnergized(grid, [("^", start)]))
            best = max(best, countEnergized(grid, [("<", start)]))
        elseif start[1] == 1
            best = max(best, countEnergized(grid, [("v", start)]))
        elseif start[1] == rows
            best = max(best, countEnergized(grid, [("^", start)]))
        elseif start[2] == 1
            best = max(best, countEnergized(grid, [(">", start)]))
        elseif start[2] == cols
            best = max(best, countEnergized(grid, [("<", start)]))
        end
    end
    return best
end

common.test(2023, 16,
    partOne,
    partTwo,
    distinct=false,
    expected=(8021, 8216),
    testExpected=(46, 51)
)
