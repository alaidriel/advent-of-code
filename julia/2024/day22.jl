include("../common/utils.jl")

using DataStructures

rounds, threshold = 2000, 0.95
mix = (secret, value) -> xor(secret, value)
prune = secret -> mod(secret, 16777216)

secrets = input -> map(initial -> foldl((current, _) -> begin
            n = last(current)
            n = prune(mix(n, n * 64))
            n = prune(mix(n, Int(fld(n, 32))))
            [current; prune(mix(n, n * 2048))]
        end, range(1, rounds), init=[initial]),
    parse.(Int, split(input, "\n")))

frequencies = windows -> begin
    counts = DefaultDict(0)
    for window in Iterators.flatmap(identity, windows)
        counts[window] += 1
    end
    counts
end

partOne = input -> sum(map(chain -> last(chain), secrets(input)))

partTwo = input -> begin
    numbers = secrets(input)
    ones = map(chain -> map(secret -> mod(secret, 10), chain), numbers)
    sequences = diff.(ones)
    windows = map(sequence -> map(i -> (i, sequence[i:i+3]), range(1, length(sequence) - 3)), sequences)
    freqs = frequencies(map(s -> Set(map(i -> i[2], s)), windows))
    best = maximum(values(freqs))
    maximum(map(window -> sum(pair -> begin
                i, sequence = pair
                indexedSequence = windows[i]
                index = findfirst(other -> window == other[2], indexedSequence)
                isnothing(index) && return 0
                j, other = indexedSequence[index]
                ones[i][j+4]
            end, enumerate(sequences)),
        collect(filter(k -> freqs[k] >= threshold * best, keys(freqs)))))
end

common.test(2024, 22,
    partOne,
    partTwo,
    distinct=true,
    expected=(20401393616, 2272),
    testExpected=(37327623, 23)
)
