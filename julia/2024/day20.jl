include("../common/utils.jl")

using DataStructures

directions = CartesianIndex.([(0, 1), (0, -1), (1, 0), (-1, 0)])

precompute = (racetrack, start, goal) -> begin
    Q, visited, dist = [(0, start, [])], Set(), DefaultDict(0)
    while !isempty(Q)
        depth, current, path = popfirst!(Q)
        current ∈ visited && continue
        dist[current] = depth
        push!(visited, current)
        current == goal && return dist, [path; current]
        for direction in directions
            next = current + direction
            checkbounds(Bool, racetrack, next) && racetrack[next] != "#" && push!(Q, (depth + 1, next, [path; current]))
        end
    end
end

findCheats = (racetrack, path, maxDepth) -> begin
    cheats = DefaultDict(Set)
    for enter in CartesianIndices(racetrack)
        racetrack[enter] == "#" && continue
        Q, visited = [(0, enter)], Set()
        while !isempty(Q)
            depth, current = popfirst!(Q)
            depth > maxDepth && break
            current ∈ visited && continue
            push!(visited, current)
            if current != enter && racetrack[current] != "#"
                enterAt = findfirst(index -> path[index] == enter, range(1, length(path)))
                exitAt = findfirst(index -> path[index] == current, range(1, length(path)))
                exitAt > enterAt && push!(cheats[enter], (depth, current))
            end
            for direction in directions
                next = current + direction
                checkbounds(Bool, racetrack, next) && push!(Q, (depth + 1, next))
            end
        end
    end
    cheats
end

interests = racetrack -> (
    findfirst(index -> racetrack[index] == "S", CartesianIndices(racetrack)),
    findfirst(index -> racetrack[index] == "E", CartesianIndices(racetrack)))

solveWith = (input; maxDepth = 2) -> begin
    racetrack = stack(split.(split(input, "\n"), ""), dims=1)
    start, goal = interests(racetrack)
    (dist, path) = precompute(racetrack, start, goal)
    cheats = findCheats(racetrack, path, maxDepth)
    saves = DefaultDict(0)
    for enter in filter(enter -> haskey(cheats, enter), path)
        for (depth, exit) in cheats[enter]
            saves[dist[exit]-dist[enter]-depth] += 1
        end
    end
    sum(map(key -> saves[key], filter(key -> key >= 100, collect(keys(saves)))), init=0)
end

partOne = input -> solveWith(input)

partTwo = input -> solveWith(input, maxDepth=20)

common.test(2024, 20,
    partOne,
    partTwo,
    distinct=false,
    expected=(1307, 986545),
    testExpected=(0, 0)
)
