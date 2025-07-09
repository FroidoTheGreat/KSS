local Object = require 'Object'
local V = require 'Vector'
local Map = Object:extend()

function Map:new(name)
	local level_data = require ('levels/'..name..'/data')
	self.data = level_data

	self.borders = level_data.borders -- FIXME: don't use the actual reference, dummy
end

return Map