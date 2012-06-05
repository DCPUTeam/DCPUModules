local stack = {}

function stack_handler(state, symbol)
  -- check to see if it's our kind of symbol.
  if (symbol == "stack:save") then
    stack = {}
    if (state.cpu.registers.SP ~= 0) then
      for i = 0xFFFF, state.cpu.registers.SP, -1 do
        table.insert(stack, state.cpu.ram[i]);
      end
    end
  elseif (symbol == "stack:check") then
    -- check stack matches
    if (stack == nil) then
      print("warning: not checking stack; stack not currently saved.")
      return
    end
    local current = {}
    if (state.cpu.registers.SP ~= 0) then
      for i = 0xFFFF, state.cpu.registers.SP, -1 do
        table.insert(current, state.cpu.ram[i])
      end
    end
    local willHalt = false
    if (#stack ~= #current) then
      print("error: stack size is different between SAVE and CHECK.")
      state:_break(false)
      willHalt = true
    end
    for i = 1, #current do
      if (current[i] ~= stack[i]) then
        if (current[i] ~= nil and stack[i] ~= nil) then
          print("error: stack differs at " .. 0x10000 - i .. "; currently " .. current[i] .. " expected " .. stack[i])
          state:_break(false)
          willHalt = true
        end
      end
    end
    if (willHalt) then
      print("breaking.")
    else
      stack = {}
    end
  end
end

function setup()
  -- perform setup
  add_symbol_hook(stack_handler)
end

MODULE = {
  Type = "Debugger",
  Name = "Stack Checking Module",
  Version = "1.0"
};
