local Object = require 'Object'
local Canvas = Object:extend()

function Canvas:new(w, h, background_color)
	self.width = w
	self.height = h

	self.background_color = background_color

	self.canvas = love.graphics.newCanvas(self.width, self.height)
end

function Canvas:set()
	love.graphics.setCanvas(self.canvas)
end

function Canvas:unset()
	love.graphics.setCanvas()
end

function Canvas:draw(x, y, s)
	self:unset()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.canvas, x, y, 0, s)
end

return Canvas