local Object = require 'Object'
local V = require 'Vector'
local Boss = Object:extend()

function Boss:new(t)
	self.typ = 'boss'

	if not t then t = {} end

	t.pos = t.pos or {}
	self.pos = V(t.pos.x or 0, t.pos.y or 0)

	t.dir = t.dir or {}
	self.dir = V(t.dir.x or 0, t.dir.y or 0)

	self.speed = t.speed or 200

	self.life = t.life or 200
end

function Boss:turn_to(angle)
	local c, s = math.cos(angle), math.sin(angle)
	self.dir = V(c, s)
end

function Boss:update(dt)
	self.pos = self.pos + self.dir * self.speed * dt
end

return Boss