include("../common/utils.jl")

partOne = input -> begin
    schematics = collect(map(schematic -> stack(split.(split(schematic, "\n"), ""), dims=1), split(input, "\n\n")))
    locks, keys = foldl(((locks, keys), schematic) -> begin
            lock = all(ch -> ch == "#", first(eachrow(schematic)))
            heights = [lock ?
                       collect(map(r -> findfirst(ch -> ch != "#", r) - 2, eachrow(permutedims(schematic)))) :
                       collect(map(r -> length(r) - findfirst(ch -> ch == "#", r), eachrow(permutedims(schematic))))]
            lock ? ([locks; heights], keys) : (locks, [keys; heights])
        end, schematics, init=([], []))
    sum(map(pair -> all(i -> pair[1][i] + pair[2][i] <= 5, range(1, length(pair[1]))) ? 1 : 0,
        Iterators.product(locks, keys)))
end

partTwo = input -> nothing

common.test(2024, 25,
    partOne,
    partTwo,
    distinct=false,
    expected=(3690, nothing),
    testExpected=(3, nothing)
)
