local objects = require 'objects'
local Projectile = objects.get('projectile')
local V = require 'Vector'

local s = {}

function s:post_load()
	self.passive_timeout = 1.5
	self.shoot_timeout = 5.5
	self.bounce_timeout = 15

	self.fire_timer = 0
	self.fire_timeout = 0.3
	self.fire_dir = 0
	self.fire_spin_speed = math.pi / 4

	self.damage = 20

	self.awake = false

	self.stage_timer = 5+math.random()*3
	self.stage = 0
	self.vel = V(600, 0)
end

function s:set_passive(world)
	self.stage = 0
	self.stage_timer = self.passive_timeout

	-- find closest player and turn towards them
	local min_player
	local min_distance
	for _, player in ipairs(world.players) do
		local distance = (self.pos - player.pos):mag2()
		if (distance < 500^2) and (player.life > 0) and ((not min_player) or (distance < min_distance)) then
			min_player = player
			min_distance = distance
		end
	end
	self.vel = V(600, 0)
	if min_player then
		self:turn_to(min_player)
	else
		self:turn(math.random() * math.pi * 2)
	end
end

function s:post_update(dt, world)
	if self.life <= 0 then
		self.purge = true
	end

	self.stage_timer = self.stage_timer - dt
	if self.stage == 0 then -- passive
		if self.stage_timer <= 0 then
			self.stage = 1
			self.stage_timer = self.shoot_timeout
			self.awake = true
		end
	elseif self.stage == 1 then
		if self.stage_timer <= 0 then
			self:set_passive(world)
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

function s:wall()

end

return s