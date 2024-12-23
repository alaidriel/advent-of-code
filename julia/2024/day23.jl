include("../common/utils.jl")

using DataStructures

graph = input -> foldl((G, connection) -> begin
        lhs, rhs = split(connection, "-")
        push!(G[lhs], rhs)
        push!(G[rhs], lhs)
        G
    end, split(input, "\n"), init=DefaultDict(Set))

partOne = input -> begin
    G = graph(input)
    components, nodes = Set(), keys(G)
    for (a, b, c) in Iterators.filter(items -> length(Set(items)) == 3, Iterators.product(nodes, nodes, nodes))
        if startswith(a, "t") || startswith(b, "t") || startswith(c, "t")
            connected = (v, w, x) -> in(v, G[w]) && in(v, G[x])
            if connected(a, b, c) && connected(c, b, a) && connected(b, c, a)
                push!(components, sort([a, b, c]))
            end
        end
    end
    length(components)
end

partTwo = input -> begin
    G, cliques = graph(input), []
    # https://en.wikipedia.org/wiki/Bron–Kerbosch_algorithm#Without_pivoting
    generate = (R, P, X) -> begin
        isempty(P) && isempty(X) && push!(cliques, join(sort(collect(R)), ","))
        for v in P
            generate(union(R, Set([v])), intersect(P, G[v]), intersect(X, G[v]))
            P = setdiff(P, Set([v]))
            X = union(X, Set([v]))
        end
    end
    generate(Set(), keys(G), Set())
    M = maximum(map(length, cliques))
    cliques[findfirst(clique -> length(clique) == M, cliques)]
end

common.test(2024, 23,
    partOne,
    partTwo,
    distinct=true,
    expected=(1194, "bd,bu,dv,gl,qc,rn,so,tm,wf,yl,ys,ze,zr"),
    testExpected=(7, "co,de,ka,ta")
)
