local s = {}

function s:post_load()
	self:turn_to(math.random() * 2 * math.pi)

	self.turn_speed = 1
	self.turn_timer = 0
end

function s:post_update(dt)
	if self.life <= 0 then
		self.purge = true
	end

	self.turn_timer = self.turn_timer - dt
	if self.turn_timer <= 0 then
		self.turn_timer = self.turn_speed

		self:turn_to(math.random() * 2 * math.pi)
	end
end

function s:hit(other)
	if other.owner_id ~= self.id then
		self.life = self.life - (other.damage or 5)
		other.purge = true
	end
end

return s