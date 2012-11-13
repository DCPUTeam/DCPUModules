local interrupt_active = nil
local interrupt_return = nil

function interrupt_handler(state, pos)
  -- we have entered an interrupt.  PC and A are
  -- their new values and pos indicates the location
  -- where the old interrupt was called from.
  if (interrupt_active ~= nil or interrupt_return ~= nil) then
    print("Interrupt occurring in the middle of an already running interrupt handler.")
    state:_break(false)
    return
  end
  interrupt_active = state.cpu.registers.pc
  interrupt_return = pos
end

function precycle_handler(state, pos)
  -- disassemble the next instruction and see whether
  -- it is RFI.
  local inst = state.cpu:disassemble(state.cpu.registers.pc)
  if (inst.pretty.op == "RFI") then
    if (interrupt_active == nil or interrupt_return == nil) then
      print("RFI encountered without being inside an interrupt handler.")
      state:_break(false)
    else
      if (state.cpu.ram[state.cpu.registers.sp + 1] ~= interrupt_return) then
        print("RFI is not returning to the expected position.")
        state:_break(false)
      else
        -- interrupt handled correctly
        interrupt_active = nil
        interrupt_return = nil
      end
    end
  end
end

function postcycle_handler(state, pos)
  -- ensure that the interrupt queue is never turned off
  -- during an interupt handler
  if (not state.cpu.irq.enabled and interrupt_active ~= nil and interrupt_return ~= nil) then
    print("Interrupt queue was turned off while inside an interrupt handler.")
    print("(caused by instruction just executed)")
    state:_break(false)
  end
end

function setup()
  -- perform setup
  add_hook("interrupt", interrupt_handler)
  add_hook("precycle", precycle_handler)
  add_hook("postcycle", postcycle_handler)
end

MODULE = {
  Type = "Debugger",
  Name = "Interrupt Verification Module",
  Version = "1.0",
  SDescription = "Checks interrupt handlers at runtime",
  URL = "http://dcputoolcha.in/docs/modules/list/inttrace.html"
};
