-- server side player
local objects = require 'objects'
local V = require 'Vector'
local s = {}

function s:post_load()
	self.shoot_delay = 0.3
	self.shoot_timer = 0

	self.AB2_timer = 0
	self.AB2_delay = 1
end

function s:post_update(dt, world)
	if self.life <= 0 then return end
	
	self.shoot_timer = self.shoot_timer - dt
	if self.controls and self.controls.AB1.p and self.shoot_timer < 0 then
		self.shoot_timer = self.shoot_delay;
		(self.main_attack or self.shoot)(self, world)
	end

	if self.controls and self.controls.AB1.p and self.shoot_timer < 0 then
		self.shoot_timer = self.shoot_delay;
		(self.main_attack or self.shoot)(self, world)
	end
end

function s:shoot(world, d)
	local d = d or V(self.controls.AB1.x, self.controls.AB1.y)
	world:add(objects.get('projectile')({
		pos = {
			x = self.pos.x,
			y = self.pos.y
		},
		vel = {
			x = d.x * self.projectile_speed,
			y = d.y * self.projectile_speed,
		},
		timer = 0.5,
		owner_id = self.id,
		damage = self.projectile_damage,
	})) -- create a new projectile!
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