include("../common/utils.jl")

mapping = Dict(
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
)

function calibrationValue(line)
    i = findfirst(isdigit, line)
    j = findlast(isdigit, line)
    return parse(Int, string(line[i]) * string(line[j]))
end

function advancedCalibrationValue(line)
    current = ""
    digits = []
    for ch in line
        current *= ch
        firstMatch = match(r"one|two|three|four|five|six|seven|eight|nine|[0-9]", current)
        if !isnothing(firstMatch)
            textNum = haskey(mapping, firstMatch.match)
            s = textNum ?
                mapping[firstMatch.match] :
                firstMatch.match
            current = textNum ? firstMatch.match[length(firstMatch.match)] : ""
            append!(digits, s)
        end
    end
    return parse(Int, string(digits[1]) * string(digits[length(digits)]))
end

partOne = (input) -> reduce(+, map(calibrationValue, split(input, "\n")))
partTwo = (input) -> reduce(+, map(advancedCalibrationValue, split(input, "\n")))

common.test(2023, 1,
    partOne,
    partTwo,
    distinct=true,
    expected=(56397, 55701),
    testExpected=(142, 281)
)