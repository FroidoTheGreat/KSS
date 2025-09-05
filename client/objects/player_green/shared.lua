local Player = require "objects/player/shared"
local Green = Player:extend()

function Green:new(t)
	t.name = 'green'
	Green.super.new(self, t)
end

return Green