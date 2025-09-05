local Object = require 'Object'
local physics = require 'physics'
local V = require 'Vector'
local Boss = Object:extend()

function Boss:new(t)
	self.typ = 'boss'

	if not t then t = {} end

	t.pos = t.pos or {}
	self.pos = V(t.pos.x or 0, t.pos.y or 0)

	self.vel = V(0, 0)

	self.speed = t.speed or 200

	self.life = t.life or 100

	self.radius = 35

	physics.load(self, {
		radius = 35,
		collision_type = 'bounce',
		bounce_damping = 0.8,
		entity_collision = true,
		entity_collision_type = 'bounce',
	})
end

function Boss:turn_to(angle)
	if type(angle) == 'table' then
		if angle.pos then
			local dir = (angle.pos - self.pos):normal()
			local magnitude = self.vel:magnitude()
			self.vel = dir * magnitude
		end
		return
	end
	local c, s = math.cos(angle), math.sin(angle)
	local magnitude = self.vel:magnitude()
	self.vel = V(c, s) * magnitude
end

function Boss:turn(angle)
	angle = angle + math.atan2(self.vel.y, self.vel.x)
	self:turn_to(angle)
end

function Boss:update(dt, world)
	if type(self.stage) == 'number' and self.stage ~= 0 then
		physics.move(self, self.vel * dt, world)
	end
end

return Boss