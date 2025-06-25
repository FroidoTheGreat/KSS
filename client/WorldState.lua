local Object = require 'Object'
local net = require 'net'
local serpent = require 'serpent'
local WorldState = Object:extend()

function WorldState:new(world, settings)
	settings = settings or {}
	self.settings = settings
	self.data = {H = settings.header or 'update'}
	local items = world.items
	self.data.items = {}

	for _, object in ipairs(items) do
		local datum = {}

		datum.id = object.id
		if self.settings.header == 'load' then
			datum.typ = object.typ
		end
		if object.pos then
			datum.x = object.pos.x
			datum.y = object.pos.y
		end

		table.insert(self.data.items, datum)
	end
end

return WorldState