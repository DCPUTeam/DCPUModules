local blocks = {}

function run_handler(state, pos)
  -- loop through all of the symbols and mark blocks
  -- of memory that are protected
  local start = nil
  blocks = {}
  for i, v in ipairs(state:symbols()) do
    if (v.data == "protection:start") then
      start = v.address
    elseif (v.data == "protection:end") then
      table.insert(blocks, { start, v.address })
    end
  end
end

function write_handler(state, pos)
  -- check to see if the position was protected
  for i, v in ipairs(blocks) do
    if (v[1] <= pos and v[2] > pos) then
      print("protected memory was written to!  automatically")
      print("halting VM.  the address that was written to is " .. pos);
      state:_break()
      return
    end
  end  
end

function setup()
  -- perform setup
  add_hook("run", run_handler)
  add_hook("write", write_handler)
end

MODULE = {
  Type = "Debugger",
  Name = "Memory Protection Module",
  Version = "1.0"
};
