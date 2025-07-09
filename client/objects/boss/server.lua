local objects = require 'objects'
local Projectile = objects.get('projectile')
local V = require 'Vector'

local s = {}

function s:post_load()
	self:turn_to(math.random() * 2 * math.pi)

	self.turn_speed = 1
	self.turn_timer = 0

	self.stage = 0

	self.stage_timer = 60
	self.passive_timeout = 3
	self.shoot_timeout = 15
	self.bounce_timeout = 15

	self.fire_timer = 0
	self.fire_timeout = 0.3
	self.fire_dir = 0
	self.fire_spin_speed = math.pi / 4

	self.damage = 20

	self.awake = false
end

function s:post_update(dt, world)
	if self.life <= 0 then
		self.purge = true
	end

	if self.stage == 0 then -- passive
		self.stage_timer = self.stage_timer - dt
		if self.stage_timer <= 0 then
			if (self.life <= 200) and (math.random() < (1 - self.life / 200)) then
				self.vel = V(400, 0)
				self:turn(math.random() * math.pi * 2)

				self.stage = 2
				self.stage_timer = self.bounce_timeout
			else
				self.vel = V(600, 0)
				self:turn(math.random() * math.pi * 2)
				
				self.stage = 1
				self.stage_timer = self.shoot_timeout
			end
		end
	elseif self.stage == 1 then
		self.stage_timer = self.stage_timer - dt
		if self.stage_timer <= 0 then
			self.stage = 0
			self.stage_timer = self.passive_timeout
		end
	elseif self.stage == 2 then
		self.stage_timer = self.stage_timer - dt
		if self.stage_timer <= 0 then
			self.stage = 0
			self.stage_timer = self.passive_timeout
		end
	end

	for _, other in ipairs(world.items) do
		if other.id ~= self.id then
			-- square of combined radii
			local rad2 = ((self.radius or 10) + (other.radius or 50)) ^ 2
			-- square of distance
			local dist2 = (other.pos - self.pos):mag2()

			if dist2 < rad2 then
				self:hit(other)
				if other.hit then
					other:hit(self)
				end
			end
		end
	end
end

function s:hit(other)
	if other.typ == 'projectile' and other.owner_id ~= self.id then
		self.life = self.life - (other.damage or 5)
		other.purge = true
	elseif other.typ == 'player' then
		--[[self:turn_to(other)
		self:turn(math.pi)]]
	elseif other.typ == 'boss' and not other.awake then
		other.awake = true
		other.stage_timer = 0
	end
	if not self.awake then
		self.awake = true
		self.stage_timer = 0
	end
end

return s