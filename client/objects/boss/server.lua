local s = {}

function s:post_update(dt)
	if self.life <= 0 then
		self.purge = true
	end
end

function s:hit(other)
	if other.owner_id ~= self.id then
		self.life = self.life - (other.damage or 5)
		other.purge = true
	end
end

return s