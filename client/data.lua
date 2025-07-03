local v = require('Vector')
local serpent = require('serpent')
local data = {}

function data.pack(t)
	--[[
	local buffer = {}
	table.insert(buffer, 'H="'..(t.H or 'BLANK')..'"')

	for k,v in pairs(t) do
		if k ~= 'H' then
			if k == 'items' then
				table.insert(buffer, ',items={')
				for _, datum in ipairs(v) do
					if _ ~= 1 then
						table.insert(buffer, ',')
					end
					table.insert(buffer, '{')
					local c = 0
					for attr, value in pairs(datum) do
						c=c+1
						if c ~= 1 then
							table.insert(buffer, ',')
						end
						if type(value) == 'string' then
							value = '"'..value..'"'
						elseif type(value) == 'table' then
							if value.isVector then --FIXME: may be inneficient
								value = '{x='..value.x..',y='..value.y..'}'
							else
								value = 'nil'
								print('WARNING: trying to send a table')
							end
						else
							value = tostring(value)
						end
						table.insert(buffer, attr..'='..value)
					end
					table.insert(buffer, '}')
				end
				table.insert(buffer, '}')
			else
				if type(v) == 'string' then
					v = '"'..v..'"'
				else
					v = tostring(v)
				end
				table.insert(buffer, ','..k..'='..v)
			end
		end
	end
	return table.concat(buffer)]]

	return serpent.dump(t)
end

function data.unpack(s)
	--[[
	buffer = {
		'do local _={',
		s,
		'};return _; end'
	}
	local success, v = serpent.load(table.concat(buffer))
	if not success then
		print('WARNING: bad data')
		return {H='ERROR'}
	end
	return v]]
	local _, d = serpent.load(s)
	return d
end

print('loaded data module...')
return data