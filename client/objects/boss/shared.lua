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

	self.radius = 45
end

function Boss:turn_to(angle)
	if type(angle) == 'table' then
		if angle.pos then
			self.dir = (angle.pos - self.pos):normal()
		end
		return
	end
	local c, s = math.cos(angle), math.sin(angle)
	self.dir = V(c, s)
end

function Boss:turn(angle)
	angle = angle + math.atan2(self.dir.y, self.dir.x)
	self:turn_to(angle)
end

function Boss:update(dt)
	if type(self.stage) == 'number' and self.stage ~= 0 then
		self.pos = self.pos + self.dir * self.speed * dt
	end

	local r = 20
	if self.pos.x > 400 - r or self.pos.x < r then
		self.pos = V(math.max(math.min(self.pos.x, 400 - r), r), self.pos.y)
		self.dir = V(self.dir.x * -1, self.dir.y)
	end
	if self.pos.y > 400 - r or self.pos.y < r then
		self.pos = V(self.pos.x, math.max(math.min(self.pos.y, 400 - r), r))
		self.dir = V(self.dir.x, self.dir.y * -1)
	end
end

return Boss