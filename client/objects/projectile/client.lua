local Color = require 'Color'
local Sprite = require 'Sprite'
local s = {}

function s:post_load()
	self.sprite = Sprite('projectile.1')
end

function s:post_update(dt)
	
end

function s:draw()
	Color.reset()
	self.sprite:draw(self.pos.x, self.pos.y)
end

return s