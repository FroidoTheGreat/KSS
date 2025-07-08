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
				self.speed = 100
				self.stage = 2
				self.stage_timer = self.bounce_timeout
			else
				self.speed = 200
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

		self.turn_timer = self.turn_timer - dt
		if self.turn_timer <= 0 then
			self.turn_timer = self.turn_speed + math.random() - 0.5

			local player = world.players[math.floor(math.random()*#world.players)+1]
			if player and math.random() < 0.8 then
				self:turn_to(player)
			else
				self:turn_to(math.random() * 2 * math.pi)
			end

			local bullets = 5
			local angle = math.pi * 2 / bullets
			local dir = math.random()
			for i=1, bullets do
				dir = dir + angle
				world:add(Projectile({
					pos = self.pos,
					vel = (V(math.cos(dir), math.sin(dir)) * 200) + ((self.dir * self.speed) / 2),
					owner_id = self.id,
					damage = 20
				}))
			end
		end
	elseif self.stage == 2 then
		self.stage_timer = self.stage_timer - dt
		if self.stage_timer <= 0 then
			self.stage = 0
			self.stage_timer = self.passive_timeout
		end

		self.fire_timer = self.fire_timer - dt
		if self.fire_timer <= 0 then
			self:turn(0.1)
			self.speed = math.min(self.speed + 70, 500)
			self.fire_dir = self.fire_dir + self.fire_spin_speed
			self.fire_timer = self.fire_timeout
			world:add(Projectile({
				pos = self.pos,
				vel = (V(math.cos(self.fire_dir), math.sin(self.fire_dir)) * 200) + ((self.dir * self.speed) / 2),
				owner_id = self.id,
				damage = 20
			}))
		end
	end
end

function s:hit(other)
	if other.typ == 'projectile' and other.owner_id ~= self.id then
		self.life = self.life - (other.damage or 5)
		other.purge = true
	elseif other.typ == 'player' then
		self:turn_to(other)
		self:turn(math.pi)
	end
	if not self.awake then
		self.awake = true
		self.stage_timer = 0
	end
end

return s