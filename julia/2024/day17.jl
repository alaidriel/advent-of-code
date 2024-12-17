include("../common/utils.jl")

runProgram = (registers, program; partTwo=false) -> begin
    output = []
    ptr = 0
    while ptr < length(program)
        op, operand = program[ptr+1], program[ptr+2]
        combo = Dict(0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => registers[1], 5 => registers[2], 6 => registers[3])
        if op == 0
            registers[1] = trunc(registers[1] / 2^combo[operand])
        elseif op == 1
            registers[2] = registers[2] ⊻ operand
        elseif op == 2
            registers[2] = mod(combo[operand], 8)
        elseif op == 3
            if registers[1] != 0
                ptr = operand - 2
            end
        elseif op == 4
            registers[2] = registers[2] ⊻ registers[3]
        elseif op == 5
            append!(output, combo[operand])
        elseif op == 6
            registers[2] = div(registers[1], 2^combo[operand])
        elseif op == 7
            registers[3] = div(registers[1], 2^combo[operand])
        end
        ptr += 2
    end
    join(map(out -> mod(out, 8), output), ",")
end

partOne = input -> begin
    nums = parse.(Int, map(m -> m.match, eachmatch(r"\d+", input)))
    registers, program = nums[1:3], nums[4:length(nums)]
    runProgram(registers, program)
end

partTwo = input -> begin
    nums = parse.(Int, map(m -> m.match, eachmatch(r"\d+", input)))
    registers, goal = nums[1:3], nums[4:length(nums)]
    index = 0
    A = 1
    while index < length(goal)
        registers[1] = A
        output = parse.(Int, split(runProgram(registers, goal), ","))
        while output != goal[length(goal)-index:length(goal)]
            A += 1
            registers[1] = A
            output = parse.(Int, split(runProgram(registers, goal), ","))
        end
        index += 1
        A *= 8
    end
    A / 8
end

common.test(2024, 17,
    partOne,
    partTwo,
    distinct=true,
    expected=("7,1,3,7,5,1,0,3,4", 190384113204239),
    testExpected=("4,6,3,5,6,3,5,2,1,0", 117440)
)
