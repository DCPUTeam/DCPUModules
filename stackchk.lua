local stack = {};

function stack_handler(state, params)
  -- we expect a single parameter that is an expression.
  if (#params ~= 1 or (params[1].value ~= "SAVE" and params[1].value ~= "CHECK")) then
    error("error: .STACK directive expects SAVE or CHECK.")
  end
  
  -- do different things based on argument.
  if (params[1].value == "SAVE") then
    state:add_symbol("stack:save")
  else
    state:add_symbol("stack:check")
  end
end

function setup()
  -- perform setup
  add_preprocessor_directive("STACK", stack_handler)
end

MODULE = {
  Type = "Preprocessor",
  Name = ".STACK directive",
  Version = "1.0"
};

