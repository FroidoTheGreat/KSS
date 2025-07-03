-- server side player
local objects = require 'objects'
local s = {}

function s:post_update(dt, world)
	if self.controls and self.controls.AB1.p then
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
			timer = 0.3
		})) -- create a new projectile!
	end
end

return s