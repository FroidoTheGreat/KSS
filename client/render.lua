local render = {}

local renders = { -- FIXME: these will be required at some point from a 'draw' folder
	player = function(self)
		love.graphics.circle('fill', self.pos.x, self.pos.y, 20)
	end,
	projectile = function(self)
		if not self.purge then
			love.graphics.setColor(1, 0.5, 0.5, 1)
			love.graphics.circle('fill', self.pos.x, self.pos.y, 10)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
}

function render.draw(world)
	for _, object in ipairs(world.items) do
		if (renders[object.typ]) then
			renders[object.typ](object)
		end
	end
end

return render