-- server side player
local objects = require 'objects'
local V = require 'Vector'
local s = {}

function s:post_load()
	self.shoot_delay = 0.3
	self.shoot_timer = 0
end

function s:post_update(dt, world)
	if self.life <= 0 then return end
	self.shoot_timer = self.shoot_timer - dt
	if self.controls and self.controls.AB1.p and self.shoot_timer < 0 then
		self.shoot_timer = self.shoot_delay
		local vel = V(self.controls.AB1.x, self.controls.AB1.y) * 800
		world:add(objects.get('projectile')({
			pos = {
				x = self.pos.x,
				y = self.pos.y
			},
			vel = {
				x = vel.x,
				y = vel.y
			},
			timer = 0.5,
			owner_id = self.id,
			damage = 10,
		})) -- create a new projectile!
	end

	
end

function s:hit(other)
	if self.invulnerable <= 0 then
		if other.typ == 'projectile' and other.owner_id ~= self.id then
			self.life = self.life - (other.damage or 5)
			other.purge = true
			self.invulnerable = self.invulnerable_timer
		elseif other.typ == 'boss' then
			self.life = self.life - (other.damage or 5)
			self.invulnerable = self.invulnerable_timer
		end
	end
end

return s