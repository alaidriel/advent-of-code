include("../common/utils.jl")

directions = Dict("<" => CartesianIndex(0, -1), ">" => CartesianIndex(0, 1), "^" => CartesianIndex(-1, 0), "v" => CartesianIndex(1, 0))

pushable = (warehouse, box, direction, chain) -> begin
    nextIndex = box + direction
    next = warehouse[nextIndex]
    next == "." && return chain
    next == "#" && return -1
    pushable(warehouse, nextIndex, direction, chain + 1)
end

allToPush = (warehouse, box, direction) -> begin
    Q, visited = [box], Set()
    while !isempty(Q)
        current = popfirst!(Q)
        if !(current in visited) && !(warehouse[current] in [".", "#", "@"])
            push!(visited, current)
            push!(Q, current + direction)
            push!(Q, current + CartesianIndex(0, warehouse[current] == "]" ? -1 : 1))
        end
    end
    collect(visited)
end

move = (warehouse, robot, direction) -> begin
    warehouse[robot+direction] = "@"
    warehouse[robot] = "."
    robot + direction
end

extend = warehouse -> begin
    replacements = Dict("#" => ["#", "#"], "." => [".", "."], "O" => ["[", "]"], "@" => ["@", "."])
    stack(collect(map(row -> foldl((newRow, at) ->
                    reduce(vcat, [[newRow]; [replacements[at]...]]),
                row, init=[]), eachrow(warehouse))), dims=1)
end

coordinateSum = (warehouse; search = "O") -> sum(
    map(index -> warehouse[index] == search ? (index[1] - 1) * 100 + index[2] - 1 : 0,
        CartesianIndices(warehouse)))

partOne = input -> begin
    warehouse, movements = split(input, "\n\n")
    warehouse = stack(split.(split(warehouse, "\n"), ""), dims=1)
    robot = findfirst(index -> warehouse[index] == "@", CartesianIndices(warehouse))
    for movement in split(join(split(movements, "\n")), "")
        direction = directions[movement]
        nextIndex = robot + direction
        next = warehouse[nextIndex]
        next == "#" && continue
        if next == "O"
            chain = pushable(warehouse, nextIndex, direction, 1)
            if chain != -1
                for box in range(1, chain)
                    warehouse[nextIndex+direction*box] = "O"
                end
                warehouse[nextIndex] = "."
                robot = move(warehouse, robot, direction)
            end
        else
            robot = move(warehouse, robot, direction)
        end
    end
    coordinateSum(warehouse)
end

partTwo = input -> begin
    warehouse, movements = split(input, "\n\n")
    warehouse = extend(stack(split.(split(warehouse, "\n"), ""), dims=1))
    robot = findfirst(index -> warehouse[index] == "@", CartesianIndices(warehouse))
    for movement in split(join(split(movements, "\n")), "")
        direction = directions[movement]
        nextIndex = robot + direction
        next = warehouse[nextIndex]
        next == "#" && continue
        if next == "[" || next == "]"
            fill = direction == directions["<"] ? ["[", "]"] : ["]", "["]
            if direction == directions["<"] || direction == directions[">"]
                chain = pushable(warehouse, nextIndex, direction, 1)
                if chain != -1
                    for box in range(1, chain)
                        warehouse[nextIndex+direction*box] = box % 2 == 0 ? fill[1] : fill[2]
                    end
                    warehouse[nextIndex] = "."
                    robot = move(warehouse, robot, direction)
                end
            else
                toPush, scratch, placedAt = allToPush(warehouse, nextIndex, direction), copy(warehouse), Set()
                if all(item -> scratch[item+direction] != "#", toPush)
                    for item in toPush
                        scratch[item+direction] = warehouse[item]
                        push!(placedAt, item + direction)
                        if !(item in placedAt)
                            scratch[item] = "."
                        end
                    end
                    warehouse = scratch
                    robot = move(warehouse, robot, direction)
                end
            end
        else
            robot = move(warehouse, robot, direction)
        end
    end
    coordinateSum(warehouse, search="[")
end

common.test(2024, 15,
    partOne,
    partTwo,
    distinct=false,
    expected=(1505963, 1543141),
    testExpected=(10092, 9021)
)
