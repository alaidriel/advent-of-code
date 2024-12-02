include("../common/utils.jl")

isValidReport = properties -> begin
    increasing, decreasing, equal, diffMax = properties
    return (increasing || decreasing) &&
           (!(increasing && decreasing)) &&
           !equal &&
           diffMax <= 3
end

paired = list -> map(index -> [list[index], list[index+1]], range(1, length(list) - 1))

properties = report -> foldl(((increasing, decreasing, equal, diffMax), diff) -> (
        increasing || diff < 0,
        decreasing || diff > 0,
        equal || diff == 0,
        max(diffMax, abs(diff))
    ), map(pair -> diff(pair)[1], paired(report)), init=(false, false, false, 0))

reports = input -> map(line -> parse.(Int, split(line)), split(input, "\n"))

permuted = reports -> map(report -> map(i -> [report[1:i-1]; report[i+1:length(report)]], range(1, length(report))), reports)

partOne = input -> length(filter(isValidReport, map(properties, reports(input))))

partTwo = input -> length(filter(reports -> any(isValidReport, map(properties, reports)), permuted(reports(input))))

common.test(2024, 2,
    partOne,
    partTwo,
    distinct=false,
    expected=(314, 373),
    testExpected=(2, 4)
)