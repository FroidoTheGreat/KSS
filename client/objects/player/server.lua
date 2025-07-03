-- server side player
local objects = require 'objects'
local s = {}

function s:post_load()
	self.shoot_delay = 0.1
	self.shoot_timer = 0
end

function s:post_update(dt, world)
	self.shoot_timer = self.shoot_timer - dt
	if self.controls and self.controls.AB1.p and self.shoot_timer < 0 then
		self.shoot_timer = self.shoot_delay
		world:add(objects.get('projectile')({
			pos = {
				x = self.pos.x,
				y = self.pos.y
			},
			dir = {
				x = self.controls.AB1.x,
				y = self.controls.AB1.y
			},
			speed = 800,
			timer = 0.3,
			owner_id = self.id
		})) -- create a new projectile!
	end
end

function s:hit(other)
	if other.owner_id ~= self.id then
		self.life = self.life - (other.damage or 5)
		other.purge = true
	end
end

return s