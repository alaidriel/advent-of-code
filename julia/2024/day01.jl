include("../common/utils.jl")

function sides(input)
    leftS, rightS = foldl(((leftS, rightS), line) -> begin
            left, right = split(line, "   ")
            (append!(leftS, parse(Int, left)), append!(rightS, parse(Int, right)))
        end, split(input, "\n"), init=([], []))
    return (sort(leftS), sort(rightS))
end

function partOne(input)
    leftS, rightS = sides(input)
    return foldl((total, (left, right)) -> total + abs(left - right), zip(leftS, rightS), init=0)
end

function partTwo(input)
    leftS, rightS = sides(input)
    return foldl((total, left) -> total += left * count(right -> left == right, rightS), leftS, init=0)
end

common.test(2024, 1,
    partOne,
    partTwo,
    distinct=false,
    expected=(1319616, 27267728),
    testExpected=(11, 31)
)