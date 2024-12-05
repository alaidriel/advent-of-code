include("../common/utils.jl")

getRules = input -> begin
    rules = Dict()
    for line in split(split(input, "\n\n")[1], "\n")
        before, after = parse.(Int, split(line, "|"))
        rule = get!(rules, before, [])
        push!(rule, after)
    end
    return rules
end

getUpdates = input -> map(updates -> parse.(Int, split(updates, ",")), split(split(input, "\n\n")[2], "\n"))

areValidUpdates = (updates, rules) -> !any(enumerated -> begin
        i, update = enumerated
        any(check -> haskey(rules, check) && in(update, rules[check]), updates[i+1:length(updates)])
    end, enumerate(updates))

middlePages = orderings -> map(ordering -> ordering[cld(length(ordering), 2)], orderings)

partOne = input -> begin
    rules, allUpdates = getRules(input), getUpdates(input)
    return sum(middlePages(filter(updates -> areValidUpdates(updates, rules), allUpdates)))
end

partTwo = (input) -> begin
    rules, allUpdates = getRules(input), getUpdates(input)
    invalidOrderings = filter(updates -> !areValidUpdates(updates, rules), allUpdates)
    sortedOrderings = []
    for ordering in invalidOrderings
        sorted = []
        while length(ordering) > 0
            num = popfirst!(ordering)
            canPlace = !any(other -> in(other, ordering) && in(num, rules[other]), keys(rules))
            canPlace ? push!(sorted, num) : !in(num, ordering) && push!(ordering, num)
        end
        push!(sortedOrderings, sorted)
    end
    return sum(middlePages(sortedOrderings))
end

common.test(2024, 5,
    partOne,
    partTwo,
    distinct=false,
    expected=(4959, 4655),
    testExpected=(143, 123)
)
