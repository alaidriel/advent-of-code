include("../common/utils.jl")

using DataStructures

struct State
    cost::Int64
    position::CartesianIndex
    facing::CartesianIndex
end

function Base.isless(lhs::State, rhs::State)
    lhs.cost < rhs.cost
end

function Base.isequal(lhs::State, rhs::State)
    lhs.cost == rhs.cost
end

directions = Dict(
    CartesianIndex(0, 1) => [CartesianIndex(0, 1), CartesianIndex(-1, 0), CartesianIndex(1, 0)],
    CartesianIndex(0, -1) => [CartesianIndex(0, -1), CartesianIndex(-1, 0), CartesianIndex(1, 0)],
    CartesianIndex(1, 0) => [CartesianIndex(1, 0), CartesianIndex(0, -1), CartesianIndex(0, 1)],
    CartesianIndex(-1, 0) => [CartesianIndex(-1, 0), CartesianIndex(0, -1), CartesianIndex(0, 1)]
)

interests = maze -> (
    findfirst(p -> maze[p] == "S", CartesianIndices(maze)),
    findfirst(p -> maze[p] == "E", CartesianIndices(maze))
)

buildGraph = maze -> begin
    G = DefaultDict(Vector)
    for index in filter(index -> maze[index] != "#", CartesianIndices(maze))
        for facing in keys(directions)
            G[(index, facing)] = map(dir -> dir == facing ? ((dir, index + dir), 1) : ((dir, index + dir), 1001),
                filter(dir -> checkbounds(Bool, maze, index + dir) && maze[index+dir] != "#",
                    directions[facing]))
        end
    end
    G
end

solve = input -> begin
    maze = stack(split.(split(input, "\n"), ""), dims=1)
    (start, goal), G = interests(maze), buildGraph(maze)
    dist, prev = DefaultDict(typemax(Int64)), DefaultDict(Set)
    heap = MutableBinaryMinHeap([State(0, start, CartesianIndex(0, 1))])
    dist[(start, CartesianIndex(0, 1))] = 0
    while !isempty(heap)
        current = pop!(heap)
        if current.position == goal
            Q, visited = [(goal, current.facing)], Set()
            while !isempty(Q)
                cur = popfirst!(Q)
                if !(cur in visited)
                    push!(visited, cur)
                    for adj in prev[cur]
                        push!(Q, adj)
                    end
                end
            end # reverse BFS to get all nodes on shortest paths
            return current.cost, length(Set(map(item -> item[1], collect(visited))))
        end
        current.cost > dist[(current.position, current.facing)] && continue
        for ((facing, position), cost) in G[(current.position, current.facing)]
            next = State(current.cost + cost, position, facing)
            if next.cost < dist[(next.position, next.facing)]
                dist[(next.position, next.facing)] = next.cost
                # overwrite because we found a better path, invalidating the nodes previously on the best path
                prev[(next.position, next.facing)] = [(current.position, current.facing)]
                push!(heap, next)
            elseif next.cost == dist[(next.position, next.facing)]
                # add this node to the other nodes that are also on *a* path of the currently known shortest path length
                push!(prev[(next.position, next.facing)], (current.position, current.facing))
                push!(heap, next)
            end
        end
    end
end

partOne = input -> solve(input)[1] # min cost

partTwo = input -> solve(input)[2] # nodes on shortest paths

common.test(2024, 16,
    partOne,
    partTwo,
    distinct=false,
    expected=(109496, 551),
    testExpected=(11048, 64)
)
