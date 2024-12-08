include("../common/utils.jl")

findAntinodes = (grid; extend = false) -> begin
    frequencies = Set(filter(frequency -> frequency != ".", grid))
    antinodes = Set()
    for frequency in frequencies
        antennas = filter(index -> grid[index] == frequency, CartesianIndices(grid))
        for (a, b) in filter(pair -> pair[1] != pair[2], collect(Iterators.product(antennas, antennas)))
            diff = a - b
            antinodesInDirection = op -> begin
                antinode = op(a, diff)
                while checkbounds(Bool, grid, antinode)
                    push!(antinodes, antinode)
                    !extend && break
                    antinode = op(antinode, diff)
                end
            end
            antinodesInDirection(+)
            extend && antinodesInDirection(-)
        end
    end
    return length(antinodes)
end

partOne = input -> findAntinodes(stack(split.(split(input, "\n"), ""), dims=1))

partTwo = input -> findAntinodes(stack(split.(split(input, "\n"), ""), dims=1), extend=true)

common.test(2024, 8,
    partOne,
    partTwo,
    distinct=false,
    expected=(293, 934),
    testExpected=(14, 34)
)
