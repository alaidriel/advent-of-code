include("../common/utils.jl")

transpose = grid -> [
    join(grid[i][j] for i in range(1, length(grid)))
    for j in range(1, length(grid[1]))]

matches = list -> sum(
    map(item -> length([m for m in eachmatch(r"XMAS|SAMX", item, overlap=true)]),
        list))

points = grid -> reduce(vcat, map(i -> map(j -> (i, j), range(1, length(grid[i]))), range(1, length(grid))))

isValidXMas = ((r, c), grid) -> begin
    isMAS = arm -> !isnothing(match(r"MAS|SAM", arm))
    directions = [(-1, -1), (1, 1), (-1, 1), (1, -1)]
    hasSpace = all(1 <= r + dr <= length(grid) && 1 <= c + dc <= length(grid[1]) for (dr, dc) in directions)
    return grid[r][c] == "A" && hasSpace &&
           isMAS(join([grid[r-1][c-1], grid[r][c], grid[r+1][c+1]])) &&
           isMAS(join([grid[r-1][c+1], grid[r][c], grid[r+1][c-1]]))
end

partOne = (input) -> begin
    grid = [split(r, "") for r in split(input, "\n")]
    rows, columns = map(join, grid), transpose(grid)
    diagonal = ((row, col), (dr, dc)) -> begin
        s = ""
        while 1 <= row <= length(rows) && 1 <= col <= length(columns)
            s *= grid[row][col]
            row += dr
            col += dc
        end
        return s
    end
    diagonals = reduce(
        vcat,
        [
            [diagonal((1, j), (1, 1)) for j in range(1, length(rows[1]))]
            [diagonal((1, j), (1, -1)) for j in range(2, length(rows[1]))]
            [diagonal((i, 1), (1, 1)) for i in range(2, length(rows))]
            [diagonal((length(rows), j), (-1, 1)) for j in range(2, length(rows))]
        ]
    )
    return matches(rows) + matches(columns) + matches(diagonals)
end

partTwo = (input) -> begin
    grid = [split(r, "") for r in split(input, "\n")]
    return length(filter(point -> isValidXMas(point, grid), points(grid)))
end

common.test(2024, 4,
    partOne,
    partTwo,
    distinct=false,
    expected=(2462, 1877),
    testExpected=(18, 9)
)
