local Object = require 'Object'
local V = require 'Vector'
local physics = require 'physics'
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

	self.name = t.name or 'gold'

	if t.pos then
		self.pos = V(t.pos.x, t.pos.y)
	elseif t.x then
		self.pos = V(t.x, t.y or 0)
	else
		self.pos = V(0, 0)
	end

	self.vel = V(0, 0)

	self.controls = t.controls

	self.speed = 300 -- pps

	self.life = t.life or 100

	self.radius = 20

	self.name = t.name or 'blue'

	self.invulnerable = 0
	self.invulnerable_timer = 0.3

	physics.load(self, {
		radius = 25,
		collision_type = 'bounce'
	})
end

local C = 1 / math.sqrt(2)
function Player:update(dt, world)
	if self.life <= 0 then return end
	self.vel = V(0, 0)

	if self.controls then
		if self.controls.LEFT and self.controls.UP then
			self.vel = V(-1, -1) * self.speed * C
		elseif self.controls.LEFT and self.controls.DOWN then
			self.vel = V(-1, 1) * self.speed * C
		elseif self.controls.RIGHT and self.controls.UP then
			self.vel = V(1, -1) * self.speed * C
		elseif self.controls.RIGHT and self.controls.DOWN then
			self.vel = V(1, 1) * self.speed * C
		elseif self.controls.LEFT then
			self.vel = V(-1, 0) * self.speed
		elseif self.controls.RIGHT then
			self.vel = V(1, 0) * self.speed
		elseif self.controls.UP then
			self.vel = V(0, -1) * self.speed
		elseif self.controls.DOWN then
			self.vel = V(0, 1) * self.speed
		end
	end

	self.invulnerable = self.invulnerable - dt

	physics.move(self, self.vel * dt, world)
end

return Player