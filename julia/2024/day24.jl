include("../common/utils.jl")

using DataStructures

toSystem = input -> begin
    wires, connections = split(input, "\n\n")
    system = DefaultDict(0)
    for (name, value) in map(wire -> split(wire, ": "), split(wires, "\n"))
        system[name] = (|, parse(Bool, value), false)
    end
    for connection in split(connections, "\n")
        inc, outc = split(connection, " -> ")
        ina, kind, inb = split(inc)
        system[outc] = (Dict("OR" => |, "AND" => &, "XOR" => ⊻)[kind], ina, inb)
    end
    system
end

evaluate = (system, output) -> begin
    in(output, [true, false]) && return output
    op, ina, inb = system[output]
    op(evaluate(system, ina), evaluate(system, inb))
end

wiresWith = (system, ch) -> sort(collect(filter(key -> startswith(key, ch), collect(keys(system)))))

outputFor = system -> begin
    outputs = wiresWith(system, "z")
    bits = reverse(map(output -> evaluate(system, output) ? 1 : 0, outputs))
    parse(Int, "0b$(join(bits))")
end

inputInteger = (system, ch) -> parse(Int, "0b$(join(reverse(map(inp -> system[inp][2] ? 1 : 0, wiresWith(system, ch)))))")

progress = system -> begin # for solving by hand to see where incorrect wirings are
    x, y = inputInteger(system, "x"), inputInteger(system, "y")
    expected, got = x + y, outputFor(system)
    println(string(got, base=2))
    println(string(expected, base=2))
end

partOne = input -> outputFor(toSystem(input))

partTwo = input -> begin
    length(split(input, "\n")) < 100 && return nothing
    system = toSystem(input)
    swaps = [("z08", "vvr"), ("bkr", "rnq"), ("z28", "tfb"), ("z39", "mqh")]
    for (a, b) in swaps
        lhs, rhs = system[a], system[b]
        system[a] = rhs
        system[b] = lhs
    end
    progress(system)
    join(sort(collect(Iterators.flatten(swaps))), ",")
end

common.test(2024, 24,
    partOne,
    partTwo,
    distinct=false,
    expected=(58639252480880, "bkr,mqh,rnq,tfb,vvr,z08,z28,z39"),
    testExpected=(2024, nothing)
)
