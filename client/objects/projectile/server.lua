local s = {}

function s:post_update(dt)
	self.timer = (self.timer or 1) - dt
	if self.timer < 0 then
		self.purge = true
		return
	end
end

return s