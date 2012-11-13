-- Define special values
local ANY = {
	A = {},
	B = {},
	C = {},
	D = {}
};

-- Define rule system.
function instruction(opcode, paramA, paramB)
	return { op = opcode, a = paramA, b = paramB };
end
function rule(inst, paramA, paramB)
	return setmetatable({
		instructions = { instruction(inst, paramA, paramB) }
	}, {
		__add = function(a, b)
			local r = rule(a.instructions[1].op, a.instructions[1].a, a.instructions[1].b);
			for i = 2, #a.instructions do
				table.insert(r.instructions,
					instruction(a.instructions[i].op,
							a.instructions[i].a,
							a.instructions[i].b)
					)
			end
			for i = 1, #b.instructions do
				table.insert(r.instructions,
					instruction(b.instructions[i].op,
							b.instructions[i].a,
							b.instructions[i].b)
					)
			end

			return r
		end
	})
end

-- Define replacements
function _remove_trailing(state, pos)
	-- disassemble the first instruction so we can
	-- get the next one (which is the one to remove)
	local inst = state.cpu:disassemble(pos)
	local rem = state.cpu:disassemble(pos + inst.size)
	state:remove(pos + inst.size, rem.size)
	return true
end
function _remove_referenced(state, pos)
	-- disassemble the first instruction so we can
	-- remove it
	local inst = state.cpu:disassemble(pos)
	state:remove(pos, inst.size)
	return true
end
function _preserve_pop(state, pos)
	-- only valid when the numeric literal is 0x1 for
	-- second instruction
	local first = state.cpu:disassemble(pos)
	local second = state.cpu:disassemble(pos + first.size)
	if (second.b == 0x1) then
		-- valid to remove both
		state:remove(pos, first.size + second.size)
		return true
	else
		-- don't remove either
		return false
	end
end

-- Define rules
local rules = {}
rules["simple-assign-back"] = {
	match = rule(OP_SET, ANY.A, ANY.B) + rule(OP_SET, ANY.B, ANY.A),
	replace = _remove_trailing
};
rules["stack-assign-back"] = {
	match = rule(OP_SET, PUSH_POP, ANY.A) + rule(OP_SET, ANY.A, PEEK),
	replace = _remove_trailing
};
rules["preserve-pop"] = {
	match = rule(OP_SET, PUSH_POP, ANY.A) + rule(OP_ADD, SP, NXT_LIT),
	replace = _preserve_pop
};

for i = REG_A, REG_J do
	rules["nop-remove-reg_" .. string.char(string.byte("a") + (i - REG_A))] = {
		match = rule(OP_SET, i, i),
		replace = _remove_referenced
	};
end


function optimize(state)
	-- Generate a list of disassembled instructions.
	local rescan = function(state)
		local insts = {}
		local i = 0
		while i < state.wordcount do
			local inst = state.cpu:disassemble(i)
			i = i + inst.size
			insts[#insts + 1] = {
				inst = inst,
				pos = i - inst.size
			}
		end
		return insts
	end
	local insts = rescan(state)

	-- Define function for checking if a value matches ANY.
	local can_be_any = function(i)
		return (i >= REG_A and i <= REG_J) or
			(i >= VAL_A and i <= VAL_J) or
			(i >= NXT_VAL_A and i <= NXT_VAL_J) or
			i == NXT or
			i == NXT_LIT
	end

	-- Match over rules.
	for k, v in pairs(rules) do
		rule = v.match
		
		i = 1
		while i <= #insts do
			local ii = insts[i].inst
			local matched = true
			local any_state = { nil, nil, nil, nil }
			if #rule.instructions > #insts - i + 1 then
				-- We'd need to match more rules than there are instructions left
				i = i + 1
				continue
			end
			for m, mm in ipairs(rule.instructions) do
				-- Load in ANY values if applicable.
				if can_be_any(insts[i + m - 1].inst.original.a) then
					if mm.a == ANY.A and any_state[1] == nil then any_state[1] = insts[i + m - 1].inst.original.a; end
					if mm.a == ANY.B and any_state[2] == nil then any_state[2] = insts[i + m - 1].inst.original.a; end
					if mm.a == ANY.C and any_state[3] == nil then any_state[3] = insts[i + m - 1].inst.original.a; end
					if mm.a == ANY.D and any_state[4] == nil then any_state[4] = insts[i + m - 1].inst.original.a; end
				end
				if can_be_any(insts[i + m - 1].inst.original.b) then
					if mm.b == ANY.A and any_state[1] == nil then any_state[1] = insts[i + m - 1].inst.original.b; end
					if mm.b == ANY.B and any_state[2] == nil then any_state[2] = insts[i + m - 1].inst.original.b; end
					if mm.b == ANY.C and any_state[3] == nil then any_state[3] = insts[i + m - 1].inst.original.b; end
					if mm.b == ANY.D and any_state[4] == nil then any_state[4] = insts[i + m - 1].inst.original.b; end
				end

				-- Check that ANY values match.
				if mm.a == ANY.A and any_state[1] ~= insts[i + m - 1].inst.original.a then matched = false; break; end
				if mm.a == ANY.B and any_state[2] ~= insts[i + m - 1].inst.original.a then matched = false; break; end
				if mm.a == ANY.C and any_state[3] ~= insts[i + m - 1].inst.original.a then matched = false; break; end
				if mm.a == ANY.D and any_state[4] ~= insts[i + m - 1].inst.original.a then matched = false; break; end
				if mm.b == ANY.A and any_state[1] ~= insts[i + m - 1].inst.original.b then matched = false; break; end
				if mm.b == ANY.B and any_state[2] ~= insts[i + m - 1].inst.original.b then matched = false; break; end
				if mm.b == ANY.C and any_state[3] ~= insts[i + m - 1].inst.original.b then matched = false; break; end
				if mm.b == ANY.D and any_state[4] ~= insts[i + m - 1].inst.original.b then matched = false; break; end

				-- Check other values.
				if type(mm.op) == "table" or type(mm.a) == "table" or type(mm.b) == "table" then matched = false; break; end
				if type(mm.op) ~= "table" and mm.op ~= insts[i + m - 1].inst.original.op then matched = false; break; end
				if type(mm.a) ~= "table" and mm.a ~= insts[i + m - 1].inst.original.a then matched = false; break; end
				if type(mm.b) ~= "table" and mm.b ~= insts[i + m - 1].inst.original.b then matched = false; break; end
			end
			if not matched then
				i = i + 1
				continue
			end

			-- We have a match.
			if (not v.replace(state, insts[i].pos)) then
				-- We didn't perform any replace; continue.
				i = i + 1
				continue
			end

			-- Now we must rescan because the structure may have changed.
			local old = #insts
			insts = rescan(state)
			i = i + 1 - (old - #insts)
		end
	end
end

MODULE = {
	Type = "Optimizer",
	Name = "Peephole Optimizer",
	Version = "1.0",
	SDescription = "The peephole assembly optimizer",
	URL = "http://dcputoolcha.in/docs/modules/list/peephole.html"
};
