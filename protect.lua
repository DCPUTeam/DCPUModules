function protect_handler(state, params)
  -- we expect a single parameter that is an expression.
  if (#params ~= 0) then
    error("error: .PROTECT directive accepts no parameters.")
  end

  -- output a symbol for the memory protection.
  state:add_symbol("protection:start");
end

function endprotect_handler(state, params)
  -- we expect a single parameter that is an expression.
  if (#params ~= 0) then
    error("error: .ENDPROTECT directive accepts no parameters.")
  end

  -- output a symbol for the memory protection.
  state:add_symbol("protection:end");
end

function setup()
  -- perform setup
  add_preprocessor_directive("PROTECT", protect_handler)
  add_preprocessor_directive("ENDPROTECT", endprotect_handler)
end

MODULE = {
  Type = "Preprocessor",
  Name = ".PROTECT / .ENDPROTECT directive",
  Version = "1.0"
};

