local V = require('Vector')
local serpent = require('serpent')
local alias = require('alias')
local to_alias = alias.to_alias
local to_key = alias.to_key
local data = {}

local a = function(t, s)
	table.insert(t, tostring(s))
end
local n = function(t, s)
	a(t, '|')
	a(t, s)
end

function data.pack(t)
	local buffer = {}

	if t.H == 'load' then
		buffer = data.pack_load(t)
	elseif t.H == 'update' then
		buffer = data.pack_update(t)
	elseif t.H == 'me' then
		buffer = data.pack_me(t)
	elseif t.H == 'connected' then
		buffer = data.pack_connected(t)
	elseif t.H == 'act' or t.H == 'unact' then
		buffer = data.pack_act(t)
	elseif t.H == 'connect' then
		buffer = data.pack_connect(t)
	else
		error('cannot pack command because header '..tostring(t.H)..' is unknown')
	end

	local s = table.concat(buffer)
	local compare = false
	if compare then
		local s2 = serpent.block(t)
		print('saved: ', (#s2 / #s))
	end

	return s
end

function data.pack_act(t)
	local buffer = {}

	a(buffer, 'A')
	if t.H == 'act' then
		a(buffer, 't')
	else
		a(buffer, 'f')
	end
	a(buffer, t.k)
	if t.x then
		n(buffer, t.x)
		a(buffer, ':')
		a(buffer, t.y)
	end

	return buffer
end

-- FIXME: combine this kind of stuff into one header
function data.pack_connected(t)
	local buffer = {}

	a(buffer, 'C')

	return buffer
end
function data.pack_connect(t)
	local buffer = {}

	a(buffer, 'N')

	return buffer
end

function data.pack_me(t)
	local buffer = {}

	a(buffer, 'M')
	a(buffer, t.id)

	return buffer
end

function data.pack_load(t)
	local buffer = {}

	a(buffer, 'L')
	a(buffer, t.level_name)
	n(buffer, t.num_players)

	return buffer
end

function data.pack_update(t)
	local buffer = {}

	a(buffer, 'U')

	for _, datum in ipairs(t.items) do
		if _ ~= 1 then
			a(buffer, ',')
		end
		data.pack_datum(buffer, datum)
	end

	return buffer
end

-- serializes an object update
function data.pack_datum(buffer, datum)
	a(buffer, datum.id)
	local i = 1
	for k, v in pairs(datum) do
		if k~='id' then
			n(buffer, to_alias[k])
			data.get_value(buffer, v)
		end
		i = i + 1
	end
end
function data.get_value(buffer, v)
	if type(v) == 'table' and v.isVector then
		a(buffer, v[1])
		a(buffer, ':')
		a(buffer, v[2])
	else
		a(buffer, v)
	end
end

function data.unpack(s)
	local t = {}

	-- FIXME: maybe just use the capital letter as the header in the first place
	local H = string.sub(s, 1, 1)
	if H == 'N' then
		t.H = 'connect'
	elseif H == 'C' then
		t.H = 'connected'
	elseif H == 'L' then
		data.unpack_load(t, string.sub(s, 2))
	elseif H == 'U' then
		data.unpack_update(t, string.sub(s, 2))
	elseif H == 'M' then
		data.unpack_me(t, string.sub(s, 2))
	elseif H == 'A' then
		data.unpack_act(t, string.sub(s, 2))
	end
	
	return t
end

function data.unpack_act(t, s)
	local v = string.sub(s, 1, 1)
	if v == 't' then
		t.H = 'act'
	else
		t.H = 'unact'
	end

	local args = data.parse(string.sub(s,2))

	t.k = args[1]
	if args[2] then
		local xy = data.parse(args[2], ':')
		t.x = tonumber(xy[1])
		t.y = tonumber(xy[2])
	end
end

function data.unpack_load(t, s)

	t.H = 'load'

	local args = data.parse(s)
	t.level_name = args[1]
	t.num_players = tonumber(args[2])
end

function data.unpack_me(t, s)
	t.H = 'me'
	t.id = tonumber(s)
	if not t.id then
		error('no me id!')
	end
end

function data.unpack_update(t, s)
	t.H = 'update'
	t.items = {}

	local items = data.parse(s, ',')
	for _, item_s in ipairs(items) do
		table.insert(t.items, data.unpack_item(item_s))
	end
end
function data.unpack_item(s)
	local args = data.parse(s)
	local datum = {}
	for _, arg in ipairs(args) do
		if _ == 1 then
			datum.id = tonumber(arg)
		else
			local alias = string.sub(arg, 1, 1)
			local name = to_key[alias]
			datum[name] = data.parse_value(string.sub(arg, 2))
		end
	end
	return datum
end
-- FIXME: types should be in exports.lua - this could cause serious problems!
function data.parse_value(s)
	local num = tonumber(s)
	if num then
		return num
	end
	local xy = data.parse(s, ':')
	if #xy == 2 then
		local x = tonumber(xy[1])
		local y = tonumber(xy[2])
		if x and y then
			return V(x, y)
		end
	end
	if s == 'true' then
		return true
	elseif s == 'false' then
		return false
	end
	return s
end

function data.parse(s, sep)
	local args = {}
	local i = 1
	for arg in string.gmatch(s, '([^'..(sep or '|')..']+)') do
		args[i] = arg
		i = i + 1
	end
	return args
end

return data