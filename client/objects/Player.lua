local Object = require 'Object'
local v = require 'Vector'
local Player = Object:extend()

function Player:new(t)
	if type(t) ~= 'table' then
		return
	end

	if t.pos then
		self.pos = pos
	elseif t.x then
		self.pos = v(t.x, t.y or 0)
	end
end

function Player:update(dt)
	self.pos = self.pos + v(dt * 100, 0)
	if self.pos.x > 500 then
		self.pos.x = 100
	end
end

function Player:draw()
	love.graphics.circle('fill', self.pos.x, self.pos.y, 20)
end

return Player