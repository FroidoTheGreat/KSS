local render = {}

local renders = { -- FIXME: these will be required at some point from a 'draw' folder
	player = function(self)
		love.graphics.circle('fill', self.pos.x, self.pos.y, 20)

		love.graphics.setColor(1, 0.5, 0.5, 1)
		if self.life then
			local width = math.max(0, self.life / 2)
			love.graphics.rectangle('fill', self.pos.x - width/2, self.pos.y - 35, width, 5)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end,
	projectile = function(self)
		love.graphics.setColor(1, 0.5, 0.5, 1)
		love.graphics.circle('fill', self.pos.x, self.pos.y, 10)
		love.graphics.setColor(1, 1, 1, 1)
	end,
	boss = function(self)
		love.graphics.circle('fill', self.pos.x, self.pos.y, 40)

		love.graphics.setColor(1, 0.5, 0.5, 1)
		love.graphics.circle('line', self.pos.x, self.pos.y, 43)
		if self.life then
			local width = math.max(0, self.life / 2)
			love.graphics.rectangle('fill', self.pos.x - width/2, self.pos.y - 55, width, 5)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end
}

function render.draw(world)
	for _, object in pairs(world.items) do
		if (renders[object.typ]) then
			renders[object.typ](object)
		end
	end
end

return render