include("../common/utils.jl")

partOne = (input) -> sum(
    map(mul -> prod(parse.(Int, mul.captures[1:2])),
        eachmatch(r"mul\((\d+),(\d+)\)", input)))

partTwo = (input) -> begin
    input = "do()$(input)"
    total = 0
    while length(input) != 1
        start, stop = match(r"do\(\)", input), match(r"don't\(\)", input)
        start, stop =
            isnothing(start) ? 1 : start.offset,
            isnothing(stop) ? length(input) : stop.offset
        start, stop = min(start, stop), max(start, stop)
        segment = input[start:stop-1]
        if !startswith(segment, r"don't\(\)")
            total += partOne(segment)
        end
        input = input[stop:length(input)]
    end
    return total
end

common.test(2024, 3,
    partOne,
    partTwo,
    distinct=true,
    expected=(174336360, 88802350),
    testExpected=(161, 48)
)
