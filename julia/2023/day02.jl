function maximumCubes(cubeCounts, revealedSet)
    revealed = eachmatch(r"(([0-9]+)\s(red|green|blue))", revealedSet)
    counts = Dict("red" => 0, "green" => 0, "blue" => 0)
    for reveal in revealed
        counts[reveal.captures[3]] += parse(Int, reveal.captures[2])
    end
    red, green, blue = cubeCounts
    return (max(red, counts["red"]), max(green, counts["green"]), max(blue, counts["blue"]))
end

function fewestCubesNeeded(line)
    _, revealedSets = split(line, ":")
    return foldl(maximumCubes, split(revealedSets, ";"), init=(0, 0, 0))
end

function powerOfCubes((red, green, blue))
    return red * green * blue
end

function possibleGame(line)
    info, revealedSets = split(line, ":")
    id = parse(Int, split(info, " ")[2])
    red, green, blue = foldl(maximumCubes, split(revealedSets, ";"), init=(0, 0, 0))
    possible = red <= 12 && green <= 13 && blue <= 14
    return if possible
        id
    else
        0
    end
end

lines = split(read("2023/inputs/day02.txt", String), "\n")
@assert reduce(+, map(possibleGame, lines)) == 2551
@assert reduce(+, map(powerOfCubes, map(fewestCubesNeeded, lines))) == 62811