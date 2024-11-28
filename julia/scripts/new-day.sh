mkdir -p "$1/inputs/tests"
touch "$1/inputs/day$2.txt"
touch "$1/inputs/tests/day$2.0.txt"
touch "$1/inputs/tests/day$2.1.txt"
touch "$1/day$2.jl"
echo 'include("../common/utils.jl")

partOne = (input) -> length(split(input, "\\n"))
partTwo = (input) -> length(split(input, "\\n"))

common.test(2024, 1,
    partOne,
    partTwo,
    distinct=false,
    expected=(1, 1),
    testExpected=(1, 1)
)' > "$1/day$2.jl"