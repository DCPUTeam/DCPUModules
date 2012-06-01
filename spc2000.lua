-- SPC2000 hardware component

-- interrupt values
local INT_GET_STATUS = 0
local INT_SET_UNIT_TO_SKIP = 1
local INT_TRIGGER_DEVICE = 2
local INT_SET_SKIP_UNIT = 3

function interrupt(cpu)
  if (cpu.registers.A == INT_GET_STATUS) then
    cpu.registers.B = 0x0006
    cpu.registers.C = 0x0000
  elseif (cpu.registers.A == INT_SET_UNIT_TO_SKIP) then
    -- pass
  elseif (cpu.registers.A == INT_TRIGGER_DEVICE) then
    -- pass
  elseif (cpu.registers.A == INT_SET_SKIP_UNIT) then
    -- pass
  end
end

MODULE = {
  Type = "Hardware",
  Name = "SPC2000",
  Version = "1.1"
};

HARDWARE = {
  ID = 0x40e41d9d,
  Version = 0x005e,
  Manufacturer = 0x1c6c8b36
};
