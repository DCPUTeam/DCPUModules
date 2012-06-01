function assert_handler(state, param)
  -- convert the parameter to an expression
  expr = expression_create(param)

  -- output a symbol for the expression.
  state:add_symbol("assertion:" .. expr:representation());
end

function setup()
  -- perform setup
  add_preprocessor_directive("ASSERT", assert_handler, false, true)
end

MODULE = {
  Type = "Preprocessor",
  Name = ".ASSERT directive",
  Version = "1.0"
};

