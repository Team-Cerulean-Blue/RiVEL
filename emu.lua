local u32limit = 4294967296 -- Intentionally lacks a -1
local bit32 = bit32 or require("bit32")

local maxMem = 1024 -- in bytes


local memData = io.open("sample.bin", "rb"):read("*a") or ""
for i = #memData + 1, maxMem do
  memData = memData .. "\0"
end
-- Use string.char() to convert numbers to memory string bytes
-- Use string.byte() to do the opposite

local regData = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} -- Data for register 0 is intentionally not in here because it is always 0
local registers = {}
setmetatable(registers, {["__index"] = function(_, key)
  local reg = {}
  function reg.set(value)
    if key > 0 and key <= 32 then
      regData[key] = value % u32limit
    end
  end

  function reg.get()
    if key == 0 then
      return 0
    else
      return regData[key]
    end
  end
  return reg
end})

-- Main loop
local pc = 0
while true do
  local instruction = string.unpack("<I4", memData:sub(pc + 1, pc + 4))
  print("Instruction: " .. tostring(instruction))
  local opcode = bit32.extract(instruction, 0, 7)
  print("opcode: " .. tostring(opcode))
  if opcode == 51 then
    -- R format
    local rd = bit32.extract(instruction, 7, 5)
    print("rd: " ..  tostring(rd))
    local funct3 = bit32.extract(instruction, 12, 3)
    print("funct3: " .. tostring(funct3))
    local rs1 = bit32.extract(instruction, 15, 5)
    print("rs1: " ..  tostring(rs1))
    local rs2 = bit32.extract(instruction, 20, 5)
    print("rs2: " .. tostring(rs2))
    local funct7 = bit32.extract(instruction, 25, 7)
    print("funct7:" .. tostring(funct7))
    local rs1val = registers[rs1].get()
    print("rs1val: " .. rs1val)
    local rs2val = registers[rs2].get()
    print("rs2val: " .. rs2val)
    if funct3 == 0 then
      if funct7 == 0 then
        print("add")
        registers[rd].set(rs1val + rs2val)
      elseif funct7 == 32 then
        print("sub")
        registers[rd].set(rs1val - rs2val)
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 4 then
      if funct7 == 0 then
        print("xor")
        registers[rd].set(bit32.bxor(rs1val, rs2val))
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 6 then
      if funct7 == 0 then
        print("or")
        registers[rd].set(rs1val | rs2val)
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 7 then
      if funct7 == 0 then
        print("and")
        registers[rd].set(rs1val & rs2val)
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 1 then
      if funct7 == 0 then
        print("sll")
        registers[rd].set(bit32.lshift(rs1val, rs2val))
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 5 then
      if funct7 == 0 then
        print("srl")
        registers[rd].set(bit32.rshift(rs1val, rs2val))
      elseif funct7 == 32 then
        print("sra")
        registers[rd].set(bit32.arshift(rs1val, rs2val))
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 2 then
      if funct7 == 0 then
        print("slt")
        local rs1signed
        if rs1 >= 0x80000000 then
          rs1signed = rs1val - 0x100000000
        else
          rs1signed = rs1val
        end
        local rs2signed
        if rs2val >= 0x80000000 then
          rs2signed = rs2val - 0x100000000
        else
          rs2signed = rs2val
        end
        if rs1val < rs2val then
          registers[rd].set(1)
        else
          registers[rd].set(0)
        end
        if rs1signed < rs2signed then
          registers[rd].set(1)
        else
          registers[rd].set(0)
        end
      else
        print("Unrecognized funct7!")
        break
      end
    elseif funct3 == 3 then
      if funct7 == 0 then
        if rs1val < rs2val then
          registers[rd].set(1)
        else
          registers[rd].set(0)
        end
      else
        print("Unrecognized funct7!")
        break
      end
    else
      print("Unrecognized funct3!")
      break
    end
  elseif opcode == 19 then
    -- I format
    local funct3 = bit32.extract(instruction, 12, 3)
    print("funct3: " .. tostring(funct3))
    local imm = bit32.extract(instruction, 20, 12)
    print("imm: " .. tostring(imm))
    local rs1 = bit32.extract(instruction, 15, 5)
    if bit32.extract(imm, 11) == 1 then
      imm = imm - 4096 -- Make it underflow for signed (negative) numbers to retain the sign
    end
    print("rs1: " .. tostring(rs1))
    local rd = bit32.extract(instruction, 7, 5)
    print("rd: " .. tostring(rd))
    if funct3 == 0 then
      print("addi")
      registers[rd].set(registers[rs1].get() + imm)
    elseif funct3 == 4 then
      print("xori")
      registers[rd].set(registers[rs1].get() ~ imm)
    elseif funct3 == 6 then
      print("ori")
      registers[rd].set(registers[rs1].get() | imm)
    elseif funct3 == 7 then
      print("andi")
      registers[rd].set(registers[rs1].get() & imm)
    elseif funct3 == 1 then
      if bit32.extract(imm, 5, 6) == 0 then -- I don't know why this is in the RISC-V spec but sure
        print("slli")
        registers[rd].set(bit32.lshift(registers[rs1].get(), bit32.extract(imm, 0, 4)))
      else
        print("Invalid immediate bits!")
        break
      end
    elseif funct3 == 5 then
      if bit32.extract(imm, 5, 6) == 0 then
        print("srli")
        registers[rd].set(bit32.rshift(registers[rs1].get(), bit32.extract(imm, 0, 4)))
      elseif bit32.extract(imm, 5, 6) == 32 then
        print("srai")
        registers[rd].set(bit32.arshift(registers[rs1].get(), bit32.extract(imm, 0, 4)))
      else
        print("Invalid immediate bits!")
        break
      end
    elseif funct3 == 2 then
      local rs1signed
      if rs1 >= 0x80000000 then
        rs1signed = registers[rs1].get() - 0x100000000
      else
        rs1signed = registers[rs1].get()
      end
      local immSigned
      if imm >= 0x80000000 then
        immSigned = imm - 0x100000000
      else
        immSigned = imm
      end
      if registers[rs1].get() < imm then
        registers[rd].set(1)
      else
        registers[rd].set(0)
      end
      if rs1signed < immSigned then
        registers[rd].set(1)
      else
        registers[rd].set(0)
      end
    elseif funct3 == 3 then
      if registers[rs1].get() < imm then
        registers[rd].set(1)
      else
        registers[rd].set(0)
      end
    else
      print("Unrecognized funct3!")
      break
    end
  elseif opcode == 3 then
    -- I format
  elseif opcode == 35 then
    -- S format
  elseif opcode == 99 then
    -- B format
  elseif opcode == 111 then
    -- J format
  elseif opcode == 103 then
    -- I format
  elseif opcode == 55 then
    -- U format
  elseif opcode == 23 then
    -- U format
  elseif opcode == 115 then
    -- I format
  else
    print("Unrecognized opcode!")
    break
  end
  pc = pc + 4
end
print("Halted.")
print("Final register status:")
print(table.unpack(regData))
