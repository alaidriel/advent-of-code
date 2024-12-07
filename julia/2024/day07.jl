include("../common/utils.jl")

checkEquations = (test, combine, index) -> begin
    index > length(combine) && return combine[1] == test ? 1 : 0
    count = 0
    afterMul, afterAdd = copy(combine), copy(combine)
    afterMul[1] *= afterMul[index]
    afterAdd[1] += afterAdd[index]
    count += checkEquations(test, afterMul, index + 1)
    count += checkEquations(test, afterAdd, index + 1)
    return count
end

checkEquationsWithConcat = (test, combine, index) -> begin
    index > length(combine) && return combine[1] == test ? 1 : 0
    count = 0
    afterMul, afterAdd, afterConcat = copy(combine), copy(combine), copy(combine)
    afterMul[1] *= afterMul[index]
    afterAdd[1] += afterAdd[index]
    afterConcat[1] = parse(Int, string(afterConcat[1]) * string(afterConcat[index]))
    count += checkEquationsWithConcat(test, afterMul, index + 1)
    count += checkEquationsWithConcat(test, afterAdd, index + 1)
    count += checkEquationsWithConcat(test, afterConcat, index + 1)
    return count
end

solveWithCheck = (input, check) -> begin
    equations = split.(split(input, "\n"), ":")
    return sum(map(equation -> begin
            test = parse(Int, equation[1])
            combine = parse.(Int, split(equation[2]))
            check(test, combine, 2) > 0 ? test : 0
        end, equations))
end

partOne = input -> solveWithCheck(input, checkEquations)

partTwo = input -> solveWithCheck(input, checkEquationsWithConcat)

common.test(2024, 7,
    partOne,
    partTwo,
    distinct=false,
    expected=(303766880536, 337041851384440),
    testExpected=(3749, 11387)
)
