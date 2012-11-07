local about_to_jump = false
local jump_origin = nil
local trace = {}

function precycle_handler(state, pos)
    inst = state.cpu:disassemble(state.cpu.registers.PC)
    if (inst.pretty.op == "JSR" or (inst.pretty.op == "SET" and inst.pretty.b == "PC")) then
        jump_origin = state.cpu.registers.PC
        about_to_jump = true
    end   
end

function postcycle_handler(state, pos)
    if about_to_jump then
        if #trace > 0 and
            trace[#trace]["from"] == jump_origin and
            trace[#trace]["to"] == state.cpu.registers.PC then
            trace[#trace]["count"] = trace[#trace]["count"] + 1
        else
            trace[#trace + 1] = {
                from = jump_origin,
                to = state.cpu.registers.PC,
                count = 1
            }
        end

        --print("Landed in " .. string.format("%04X", state.cpu.registers.PC) .. ".")
        about_to_jump = false
    end
end

function where_handler(state, params)
    --local pos = trace[#trace]["to"]
    local i = 0
    while i < 10 do
        if trace[#trace - i].count == 1 then
            print(string.format("%04X", trace[#trace - i]["to"]) .. " was jumped to from "
                .. string.format("%04X", trace[#trace - i]["from"]))
        else
            print(string.format("%04X", trace[#trace - i]["to"]) .. " was jumped to from "
                .. string.format("%04X", trace[#trace - i]["from"])
                .. " (" .. trace[#trace - i].count .. " times)")
        end
        i = i + 1
    end
end


function setup()
    add_command("where", where_handler)
    add_hook("precycle", precycle_handler)
    add_hook("postcycle", postcycle_handler)
end

MODULE = {
   Type = "Debugger",
   Name = "Backtracing",
   Version = "1.0"
};
