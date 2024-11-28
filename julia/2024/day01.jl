include("../common/utils.jl")

partOne = (input) -> length(split(input, "\n"))
partTwo = (input) -> length(split(input, "\n"))

common.test(2024, 1,
    partOne,
    partTwo,
    distinct=false,
    expected=(1, 1),
    testExpected=(1, 1)
)