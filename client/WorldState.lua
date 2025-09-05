local Object = require 'Object'
local net = require 'net'
local serpent = require 'serpent'
local exports = require 'exports'
local WorldState = Object:extend()

-- FIXME: this is weird about loading
function WorldState:new(world, settings)
	settings = settings or {}
	self.settings = settings
	self.data = {H = settings.header or 'update'}
	local items = world.items
	self.data.items = {}

	local last = settings.last

	for _, object in pairs(items) do
		local datum = {}

		-- only update what is changed
		local other
		if last then
			if last then
				other = last:find_by_id(object.id)
			end
			if not other then -- FIXME: this is where I can do delta compression in the future
				datum.typ = object.typ
			end
		end
			
		-- include the basic necessities (defaults)
		datum.id = object.id
		if object.pos then
			datum.pos = object.pos
		end

		-- include that which is shared between server and client
		-- this handles things other than the default
		if exports[object.typ] then
			for _, export in ipairs(exports[object.typ]) do
				if (not other) or (other[export] ~= object[export]) then
					local value = object[export]
					if value then
						datum[export] = value
					end
				end
			end
		end

		table.insert(self.data.items, datum)
	end

	last = last or {data={items={}}}
	for _, object in ipairs(last.data.items) do -- FIXME: inefficient
		if (not object.purge) and (not self:find_by_id(object.id)) then
			local datum = {
				id = object.id,
				purge = true
			}

			table.insert(self.data.items, datum)
		end
	end

	-- map
	if self.data.H == 'load' then
		self.data.level_name = world.level_name or '1'
		self.data.num_players = #world.players
	end
end

function WorldState:find_by_id(id)
	for _, item in pairs(self.data.items) do
		if item.id == id then
			return item
		end
	end
end

return WorldState