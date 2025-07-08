local Object = require 'Object'
local Color = Object:extend()

local hex_vals = '0123456789abcdef'

local to_dec = function(hex)
	local v = 0
	for i=1,2 do
		local c = string.sub(hex, i, i)
		local digit = string.find(hex_vals, c)
		if digit then
			digit = digit - 1
			if i == 1 then
				v = v + digit * 16
			else
				v = v + digit
			end
		else
			error('bad hex value')
		end
	end
	return v
end

local to_rgb = function(hex)
	if #hex ~= 6 then
		error('bad hex value')
	end
	local rs = string.sub(hex, 1, 2)
	local gs = string.sub(hex, 3, 4)
	local bs = string.sub(hex, 5, 6)

	return to_dec(rs) / 255, to_dec(gs) / 255, to_dec(bs) / 255
end

function Color:new(r, g, b, a)
	if type(r) == 'string' then
		-- handle hex
		a = g
		r, g, b = to_rgb(r)
	end
	self.r = r or 1
	self.g = g or 1
	self.b = b or 1
	self.a = a or 1
end

function Color:set()
	love.graphics.setColor(self.r, self.g, self.b)
end

function Color:normal()
	self.r = self.r / 255
	self.g = self.g / 255
	self.b = self.b / 255
	self.a = self.a / 255

	return self
end

function Color:clear()
	love.graphics.clear(self.r, self.g, self.b)
end

function Color.reset()
	love.graphics.setColor(1, 1, 1, 1)
end

function Color:__tostring()
	return 'Color - r:'..self.r..' g:'..self.g..' b:'..self.b
end

return Color