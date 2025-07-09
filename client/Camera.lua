local V = require 'Vector'
local Object = require 'Object'
local Camera = Object:extend()

function Camera:new(canvas)
	self.pos = V(0, 0)

	self.canvas = canvas
end

function Camera:apply(factor)
	love.graphics.origin()
	local t = self.pos
	if factor then
		t = self.pos * factor
	end
	love.graphics.translate(-t[1], -t[2])
end

function Camera:set(pos, y)
	if type(pos) == 'number' then
		self.pos = V(pos, y)
	else
		self.pos = pos
	end
end

function Camera:follow(dt, object, factor)
	local goal = (object.pos - self.canvas.dim / 2)
	local difference = (goal - self.pos)
	if difference:mag2() <= 1 then
		self:set(goal)
	else
		self.pos = self.pos + difference * factor * dt
	end
end

return Camera