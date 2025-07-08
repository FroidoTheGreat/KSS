local Color = require 'Color'
local Sprite = require 'Sprite'
local s = {}

function s:post_load()
	self.sprite = Sprite('chars.'..(self.name or 'blue'))
end

function s:post_update(dt)
	
end

function s:draw()
	if self.life <= 0 then return end
	Color.reset()
	self.sprite:draw(self.pos.x, self.pos.y)

	Color(255, 100, 100):normal():set()
	if self.life then
		local width = math.max(0, self.life / 2)
		love.graphics.rectangle('fill', self.pos.x - width/2, self.pos.y - 35, width, 5)
	end
end

return s