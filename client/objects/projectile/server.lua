local s = {}

function s:post_update(dt, world)
	self.timer = (self.timer or 1) - dt
	if self.timer < 0 then
		self.purge = true
		return
	end

	for _, other in pairs(world.items) do
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
	
end

function s:wall(num_collisions)
	self.purge = true
end

return s