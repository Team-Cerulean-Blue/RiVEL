local u32limit = 4294967296 -- Intentionally lacks a -1

local maxMem = 1024 -- in bytes


local memData = "\x00\xA0\x05\x13"
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
    regData[key] = value % u32limit
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
  local instruction = string.unpack(">I4", memData:sub(pc + 1, pc + 4))
  print("Instruction: " .. tostring(instruction))
  local opcode = bit32.extract(instruction, 0, 7)
  print("Opcode: " .. tostring(opcode))
  if opcode == 51 then

  elseif opcode == 19 then

  elseif opcode == 3 then

  elseif opcode == 35 then

  elseif opcode == 99 then

  elseif opcode == 111 then

  elseif opcode == 55 then

  elseif opcode == 23 then

  elseif opcode == 115 then

  else
    print("Unrecognized opcode!")
    break
  end
  pc = pc + 4
end
print("Halted.")
