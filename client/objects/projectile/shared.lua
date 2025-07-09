local Object = require 'Object'
local physics = require 'physics'
local V = require 'Vector'
local Projectile = Object:extend()

function Projectile:new(t)
	self.typ = 'projectile'

	if not t then t = {} end

	t.pos = t.pos or {}
	t.dir = t.dir or {}

	self.pos = V(t.pos.x or 0, t.pos.y or 0)
	self.dir = V(t.dir.x or 0, t.dir.y or 0)

	self.speed = t.speed or 100

	self.timer = t.timer or 1

	self.damage = t.damage or 5

	if t.vel then
		self.vel = V(t.vel.x or 0, t.vel.y or 0)
	else
		self.vel = self.dir * self.speed
	end

	self.owner_id = t.owner_id

	physics.load(self, {
		radius = 10,
		collision_type = 'bounce'
	})
end

function Projectile:update(dt, world)
	physics.move(self, self.vel * dt, world)
end

return Projectile