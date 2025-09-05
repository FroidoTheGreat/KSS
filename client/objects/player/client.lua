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

function s:mouse_event(button, action)
	if button == 1 then
		if action.p then
			local dir = (self.controller.mouse_p - self.pos):normal()
			return {
				H = 'act',
				k = 'AB1',
				x = dir.x,
				y = dir.y
			}
		else
			return {
				H = 'unact',
				k = 'AB1',
			}
		end
	elseif button == 2 then
		return s:mouse_2_event(action)
	end
end

function s:mouse_2_event(action)
	if action.p then
		local pos = self.controller.mouse_p
		return {
			H = 'act',
			k = 'AB2',
			x = pos.x,
			y = pos.y,
		}
	else
		return {
			H = 'unact'
			k = 'AB2'
		}
	end
end

return s