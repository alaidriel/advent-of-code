include("../common/utils.jl")

cache = Dict()

arrangements = (current, rest) -> begin
    current == 0 && return 1
    key = (current, rest)
    haskey(cache, key) && return cache[key]
    return get!(cache, key, sum(map(i ->
            arrangements(rest[i], rest[i+1:length(rest)]),
        Iterators.takewhile(i -> i <= length(rest) && current - rest[i] <= 3, range(length=length(rest))))))
end

partOne = input -> begin
    adapters = sort(parse.(Int, split(input, "\n")))
    return prod(foldl((
            (d1, d3), (left, right)) -> right - left == 1 ? (d1 + 1, d3) : (d1, d3 + 1),
        zip(adapters[1:length(adapters)], adapters[2:length(adapters)]), init=(1, 1)))
end

partTwo = input -> begin
    adapters = sort(parse.(Int, split(input, "\n")), rev=true)
    push!(adapters, 0)
    return arrangements(adapters[1] + 3, adapters)
end

common.test(2020, 10,
    partOne,
    partTwo,
    distinct=false,
    expected=(1820, 3454189699072),
    testExpected=(220, 19208)
)
