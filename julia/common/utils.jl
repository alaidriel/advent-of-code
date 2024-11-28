module common

using Test

function test(year, day, partOne, partTwo; expected=(0, 0), testExpected=(0, 0), distinct=false)
    input = common.inputFor(year, day)
    testInput = common.inputFor(year, day, test=true, testIndex=0)
    testInputP2 = distinct ?
                  common.inputFor(year, day, test=true, testIndex=1) : testInput
    @test (partOne(testInput), partTwo(testInputP2)) == testExpected
    @test (partOne(input), partTwo(input)) == expected
end

function inputFor(year, day; test=false, testIndex=0)
    day = day < 10 ? "0$(day)" : day
    file = test ? "tests/day$(day).$(testIndex).txt" : "day$(day).txt"
    return read("$(pwd())/$(year)/inputs/$(file)", String)
end

end