local Object = require 'Object'
local v = require 'Vector'
local Projectile = Object:extend()

function Projectile:new(t)
	self.typ = 'projectile'

	if not t then t = {} end

	t.pos = t.pos or {}
	t.dir = t.dir or {}

	self.pos = v(t.pos.x or 0, t.pos.y or 0)
	self.dir = v(t.dir.x or 0, t.dir.y or 0)

	self.speed = t.speed or 100

	self.timer = t.timer or 1
end

function Projectile:update(dt)
	self.pos = self.pos + self.dir * dt * self.speed
end

return Projectile