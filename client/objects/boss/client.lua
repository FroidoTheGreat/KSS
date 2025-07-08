local Color = require 'Color'
local Sprite = require 'Sprite'
local s = {}

function s:post_load()
	self.sprite = Sprite('boss.1')
	self.sprite2 = Sprite('boss.2')
end

function s:post_update(dt)
	
end

function s:draw()
	Color.reset()
	if self.stage == 1 or self.stage == 2 then
		self.sprite:draw(self.pos.x, self.pos.y)
	else
		self.sprite2:draw(self.pos.x, self.pos.y)
	end

	Color(255, 100, 100):normal():set()
	if self.life then
		local width = math.max(0, self.life / 2)
		love.graphics.rectangle('fill', self.pos.x - width/2, self.pos.y - 55, width, 5)
	end
end

return s