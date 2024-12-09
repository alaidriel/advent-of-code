include("../common/utils.jl")

checksum = fs -> sum(map(item -> item[2] == -1 ? 0 : (item[1] - 1) * item[2], enumerate(expanded(fs))))

parseToFilesystem = (input; padRight = false) -> begin
    raw = split(input, "")
    file, fs, cursor, id = true, [], 1, 0
    for ch in raw
        size = parse(Int, ch) - 1
        size != -1 && push!(fs, (file ? id : -1, (cursor, cursor + size)))
        file = !file
        cursor += size + 1
        if file
            id += 1
        end
    end
    padRight && push!(fs, (-1, (cursor, typemax(Int))))
    return fs
end

expanded = fs -> begin
    raw = []
    for (id, (start, stop)) in fs
        stop == typemax(Int) && break
        for _ in range(start, stop)
            push!(raw, id)
        end
    end
    return raw
end

isCompacted = fs -> findlast(item -> item[1] != -1, fs) < findfirst(item -> item[1] == -1, fs)

partOne = input -> begin
    fs = parseToFilesystem(input, padRight=true)
    for (id, (fileStart, fileStop)) in collect(filter(item -> item[1] != -1, reverse(fs)))
        placed = 0
        for _ in range(0, fileStop - fileStart)
            if isCompacted(fs)
                index = findlast(item -> item[1] == id, fs)
                _, (start, stop) = fs[index]
                fs[index] = (id, (start, stop - placed))
                return checksum(fs)
            end
            earliestFreeIndex = findfirst(item -> item[1] == -1, fs)
            _, (freeStart, freeStop) = fs[earliestFreeIndex]
            previousId, (pStart, pStop) = fs[earliestFreeIndex-1]
            remainingFreeIndex = if previousId == id
                fs[earliestFreeIndex-1] = (id, (pStart, pStop + 1))
                earliestFreeIndex
            else
                insert!(fs, earliestFreeIndex, (id, (freeStart, freeStart)))
                earliestFreeIndex + 1
            end
            fs[remainingFreeIndex] = (-1, (freeStart + 1, freeStop))
            freeStart + 1 > freeStop && popat!(fs, remainingFreeIndex)
            placed += 1
        end
        oldFileIndex = findlast(item -> item[1] == id, fs)
        popat!(fs, oldFileIndex)
    end
    return -1
end

partTwo = input -> begin
    fs = parseToFilesystem(input)
    for (id, (fileStart, fileStop)) in collect(filter(item -> item[1] != -1, reverse(fs)))
        currentIndex = findlast(item -> item[1] == id, fs)
        size = fileStop - fileStart
        earliestFreeIndex = findfirst(item -> item[1] == -1 && item[2][2] - item[2][1] >= size, fs)
        if !isnothing(earliestFreeIndex) && earliestFreeIndex < currentIndex
            _, (freeStart, freeStop) = fs[earliestFreeIndex]
            fs[earliestFreeIndex] = (id, (freeStart, freeStart + size))
            freeStart + size + 1 <= freeStop && insert!(fs, earliestFreeIndex + 1, (-1, (freeStart + size + 1, freeStop)))
            fs[findlast(item -> item[1] == id, fs)] = (-1, (fileStart, fileStop))
        end
    end
    return checksum(fs)
end

common.test(2024, 9,
    partOne,
    partTwo,
    distinct=false,
    expected=(6288707484810, 6311837662089),
    testExpected=(1928, 2858)
)
