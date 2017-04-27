local cmsgpack = require("cmsgpack")

local pack, upack = cmsgpack.pack, cmsgpack.unpack

local pack_errs = pack_errs or 0
local pack_set  = pack_set or {}

local total_tests = total_tests or 0

local test_data = {
	['number'] = {
		{127},
		{128},
		{254},
		{255},
		{256},
		{65535},
		{4294967295},
		{4294967296},
		{9007199254740991},
		{9007199254740990},
		{0.0},
		{0.1},
		{0.010},
		{12.123},
		{12.00},
		{1.0 / 0.0},
		{-1.0 / 0.0},
		{0.0 / 0.0},
	},
	['boolean'] = {
		{true},
		{false},
	},
	['nil'] = {
		{nil},
	},
	['table'] = {
		{{}},
		{{1, 2, 3, 4, 'x', 'y','z'}},
		{{x = 1, y = 2, z = 3, {4, 5, 6}}},
		{{1, 2, 3, nil}},
		{{1, 2, nil, 3}},
		{{500026, 155, {__entity_id = 500026 , __gate_id = 2, __server_id = 5, __type = "Player"}}},
		{{500026, 93, {autoMatchGoal = 0, autoMatchPlayerNum = 0, autoMatchTeamNum = 0, teams = {}}}},
	},
	['string'] = {
		{""},
		{" "},
		{"1234567891234567891234567891234"},
		{"checkInteractionConditionWithQuestId"},
	}
}

function __dump_table(t, level, leadSpace)
    level = level or 3
    leadSpace = leadSpace or 1

    local rlt = ""
    for idx = 1, leadSpace do
        rlt = rlt .. " "
    end

    local blacnSpace = rlt

    local len = #t
    for k, v in pairs(t) do
        if type(k) == "number" then
            rlt = rlt .. "[" .. k .. "]"
        elseif type(k) == "string" then
            rlt = rlt .. '["' .. k .. '"]'
        end

        if type(v) == "table" then
            if level > 0  then
                rlt = rlt .. " = {\n" .. __dump_table(v, level - 1, leadSpace + 4) .. "\n" .. blacnSpace .. "}, "
            else
                rlt = rlt .. " = {" .. __dump_table(v, level - 1, 0) .. "}, "
            end
        elseif type(v) == "string" then
            rlt = rlt .. ' = "' .. v .. '", '
        else
            rlt = rlt .. ' = ' .. tostring(v) .. ', '
        end

        if level >= 0 then
            rlt = rlt .. '\n' .. blacnSpace
        end

    end

    return rlt
end

function print_hex(buffer, num)
	local str = ''
	local cnt = 0
	local len = num or string.len(buffer)

	for idx = 1, len do
		str = str .. string.format("%02X",buffer:sub(idx, idx):byte()) .. ' '
		cnt = cnt + 1
	end
	print(str)
end


function dump(v)
	if type(v) ~= 'table' then
		return 	tostring(v)
	end
	
	return __dump_table(v)
end

function is_equal(dst, src)

	if type(dst) ~= type(src) then
		return false	
	end
	
	if type(dst) ~= 'table' then
		return dst == src	
	end
		
	if #dst ~= #src then
		return false	
	end
	
	for k, v in pairs(dst) do
		if type(v) ~= 'table' then
			if src[k] ~= v then
				return false
			end
		else
			return is_equal(v, src[k])
		end
	end

	return true
end


function test(v)
	--print(upack(pack(v)))
	print('pack ---------------------------- :\n', dump(v))
	local rlt = pack(v)
	print_hex(rlt)
	
	print('unpack -------------------------- :\n')
	local urlt = upack(rlt)
	print(dump(urlt))
	
	if not is_equal(urlt, v) or not is_equal(v, urlt) then
		pack_errs = pack_errs + 1
		pack_set[#pack_set + 1] = {rlt, v} 
	end
end

for k, v in pairs(test_data) do
	print('Testing-------------------------->', k)
	local td = test_data[k]
	for _, value in pairs(td) do
		test(value[1])
		total_tests = total_tests + 1
	end
end

print('Total tests: ', total_tests)
print('Error tests: ', pack_errs)
print('Passed tests: ', total_tests - pack_errs)

for k, v in pairs(pack_set) do
	print('dst:\n', dump(pack_set[1]), '\nsrc:\n', dump(pack_set[2]))
end
