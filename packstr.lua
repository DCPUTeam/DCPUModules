function packstr_handler(state, params)
   -- Packs strings into 8 bit characters, padding with a single null
   -- byte if necessary.
   if (#params ~= 1 or params[1].type ~= "STRING") then
      error("error: .PACKSTR directive expects a single string")
   end
   local s = params[1].value
   local packed = {}
   for i = 1, #s do
      if math.mod(i, 2) == 0 then
         packed[#packed] = packed[#packed] + string.byte(s, i) 
      else
         table.insert(packed, string.byte(s, i) * (2^8))
      end
   end
   for i = 1, #packed do
      state:print_line("\tdat 0x" .. string.format("%x", packed[i]))
   end
end

function setup()
   add_preprocessor_directive("packstr", packstr_handler)
end

MODULE = {
   Type = "Preprocessor",
   Name = ".PACKSTR directive",
   Version = "1.0"
};
