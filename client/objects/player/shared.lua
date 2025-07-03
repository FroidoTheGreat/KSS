local Object = require 'Object'
local v = require 'Vector'
local Player = Object:extend()

function Player:new(t, y)
	self.typ = 'player'

	if type(t) == 'number' then
		t = {
			x = t,
			y = y
		}
	elseif type(t) ~= 'table' then
		t = {}
	end

	if t.pos then
		self.pos = v(t.pos.x, t.pos.y)
	elseif t.x then
		self.pos = v(t.x, t.y or 0)
	else
		self.pos = v(0, 0)
	end

	self.controls = t.controls

	self.speed = 300 -- pps

	self.life = t.life or 100
end

local C = 1 / math.sqrt(2)
function Player:update(dt)
	if self.controls then
		if self.controls.LEFT and self.controls.UP then
			self.pos = self.pos + v(-dt * self.speed * C, -dt * self.speed * C)
		elseif self.controls.LEFT and self.controls.DOWN then
			self.pos = self.pos + v(-dt * self.speed * C, dt * self.speed * C)
		elseif self.controls.RIGHT and self.controls.UP then
			self.pos = self.pos + v(dt * self.speed * C, -dt * self.speed * C)
		elseif self.controls.RIGHT and self.controls.DOWN then
			self.pos = self.pos + v(dt * self.speed * C, dt * self.speed * C)
		elseif self.controls.LEFT then
			self.pos = self.pos + v(-dt * self.speed, 0)
		elseif self.controls.RIGHT then
			self.pos = self.pos + v(dt * self.speed, 0)
		elseif self.controls.UP then
			self.pos = self.pos + v(0, -dt * self.speed)
		elseif self.controls.DOWN then
			self.pos = self.pos + v(0, dt * self.speed)
		end

		if self.controls.AB1 then

		end
	end
end

return Player