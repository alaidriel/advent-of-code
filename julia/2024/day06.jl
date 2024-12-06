include("../common/utils.jl")

inBounds = (r, c, grid) -> 1 <= r <= length(grid) && 1 <= c <= length(grid[r])

points = grid -> reduce(vcat, map(i -> map(j -> (i, j), range(1, length(grid[i]))), range(1, length(grid))))

simulate = (coordinate, grid) -> begin
    r, c = coordinate
    directions = [(-1, 0), (0, 1), (1, 0), (0, -1)]
    visited = Set()
    hits = Dict()
    push!(visited, (r, c))
    for (dr, dc) in Iterators.cycle(directions)
        while grid[r+dr][c+dc] != "#"
            r += dr
            c += dc
            push!(visited, (r, c))
            !inBounds(r + dr, c + dc, grid) && return length(visited)
        end
        hit = get!(hits, (r + dr, c + dc), Set())
        (dr, dc) ∈ hit && return -1
        push!(hit, (dr, dc))
    end
end

partOne = input -> begin
    grid = split.(split(input, "\n"), "")
    coordinates = points(grid)
    r, c = coordinates[findfirst(map(coordinate -> grid[coordinate[1]][coordinate[2]] == "^", coordinates))]
    return simulate((r, c), grid)
end

partTwo = input -> begin
    grid = split.(split(input, "\n"), "")
    coordinates = points(grid)
    r, c = coordinates[findfirst(map(coordinate -> grid[coordinate[1]][coordinate[2]] == "^", coordinates))]
    options = filter(coordinate -> begin
            at = grid[coordinate[1]][coordinate[2]]
            at != "^" && at != "#"
        end, coordinates)
    validOptions = 0
    for option in options
        grid[option[1]][option[2]] = "#"
        if simulate((r, c), grid) == -1
            validOptions += 1
        end
        grid[option[1]][option[2]] = "."
    end
    return validOptions
end

common.test(2024, 6,
    partOne,
    partTwo,
    distinct=false,
    expected=(5131, 1784),
    testExpected=(41, 6)
)
