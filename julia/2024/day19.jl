include("../common/utils.jl")

possible = (design, patterns, cache) -> begin
    design == "" && return 1
    get!(cache, design) do
        sum(map(pattern -> possible(design[length(pattern)+1:length(design)], patterns, cache),
                filter(pattern -> startswith(design, pattern), patterns)), init=0)
    end
end

parse = input -> begin
    patterns, designs = split(input, "\n\n")
    (split(patterns, ", "), split(designs, "\n"))
end

partOne = input -> begin
    (patterns, designs), cache = parse(input), Dict()
    length(collect(filter(design -> possible(design, patterns, cache) > 0, designs)))
end

partTwo = input -> begin
    (patterns, designs), cache = parse(input), Dict()
    sum(design -> possible(design, patterns, cache), designs)
end

common.test(2024, 19,
    partOne,
    partTwo,
    distinct=false,
    expected=(360, 577474410989846),
    testExpected=(6, 16)
)
