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

registers[10].set(20)
print(registers[10].get())
registers[0].set(20)
print(registers[0].get())
registers[31].set(4294967297)
print(registers[31].get())
registers[30].set(-4294967295)
print(registers[30].get())
