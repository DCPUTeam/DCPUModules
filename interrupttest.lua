-- Test hardware for software interrupts

function interrupt(cpu)
	-- Calls the software interrupt of this hardware interrupt
	cpu.interrupt(cpu.registers.A)
end

MODULE = {
  Type = "Hardware",
  Name = "Test Hardware",
  Version = "1.0"
};

HARDWARE = {
  ID = 0x13377331,
  Version = 0x0005,
  Manufacturer = 0x12346598
};