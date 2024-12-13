include("../common/utils.jl")

delta = 0.0001

solveEquations = (input; scale = 0) -> begin
    nums = parse.(Int, map(m -> m.match, collect(eachmatch(r"\d+", input))))
    sum(i -> begin
            ax, ay, bx, by, x, y = nums[i:i+5]
            A = [[ax bx]; [ay by]]
            S = [[x + scale]; [y + scale]]
            a, b = inv(A) * S
            abs(a - round(a)) < delta && abs(b - round(b)) < delta ? Int(3 * round(a) + round(b)) : 0
        end, range(1, length(nums), step=6))
end

partOne = input -> solveEquations(input)

partTwo = input -> solveEquations(input, scale=10000000000000)

common.test(2024, 13,
    partOne,
    partTwo,
    distinct=false,
    expected=(29388, 99548032866004),
    testExpected=(480, 875318608908)
)
