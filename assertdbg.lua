function assert_handler(state, symbol)
  function resolve_label(needed)
    if (state.cpu.registers[needed] == nil) then
      state:_break()
      error("unable to resolve '" .. needed .. "' for assertion evaluation (halted vm)")
    else
      return state.cpu.registers[needed]
    end
  end
  -- check to see if it's our kind of symbol.
  if (string.sub(symbol, 0, #"assertion:") == "assertion:") then
    -- handle assertion
    local expr = expression_create(string.sub(symbol, #"assertion:" + 1))
    if (expr:evaluate(resolve_label) ~= 1) then
      -- assertion failed, break
      print("assertion \"" .. string.sub(symbol, #"assertion:" + 1) .. "\" failed.")
      state:_break()
    end
  end
end

function setup()
  -- perform setup
  add_symbol_hook(assert_handler)
end

MODULE = {
  Type = "Debugger",
  Name = "Assertion Module",
  Version = "1.0"
};
