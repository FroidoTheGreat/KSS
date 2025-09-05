local Player = require "objects/player/shared"
local Blue = Player:extend()

function Blue:new(t)
	t.name = 'blue'
	Blue.super.new(self, t)
end

return Blue