include("../common/utils.jl")

using DataStructures

blinkOnce = stones -> begin
    next = DefaultDict(0)
    for stone in keys(stones)
        if stone == 0
            next[1] += stones[stone]
        else
            n = split(string(stone), "")
            if length(n) % 2 == 0
                left, right = parse.(Int, [join(n[1:div(length(n), 2)]); join(n[div(length(n), 2)+1:length(n)])])
                for item in [left, right]
                    next[item] += stones[stone]
                end
            else
                next[stone*2024] += stones[stone]
            end
        end
    end
    return next
end

blink = (input; times = 25) -> begin
    initial = DefaultDict(0, map(item -> (item, 1), parse.(Int, split(input))))
    stones = foldl((stones, _) -> blinkOnce(stones), range(length=times), init=initial)
    return stones |> values |> sum
end

partOne = input -> blink(input)

partTwo = input -> blink(input, times=75)

common.test(2024, 11,
    partOne,
    partTwo,
    distinct=false,
    expected=(189547, 224577979481346),
    testExpected=(55312, 65601038650482)
)
