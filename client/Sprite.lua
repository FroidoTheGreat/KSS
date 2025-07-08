local Object = require 'Object'
local V = require 'Vector'
local Sprite = Object:extend()
local sprites = {}
Sprite.sprites = sprites

function sprites.load(root, t)
	root = root or 'sprites'
	
	if not t then
		sprites.sprites = {}
		t = sprites.sprites
	end

	local file_names = love.filesystem.getDirectoryItems(root)

	for _, file_name in pairs(file_names) do
		local path = root..'/'..file_name
		if #file_name > 4 and string.sub(file_name, #file_name - 3, #file_name) == '.png' then
			local name = string.sub(file_name, 1, #file_name - 4)

			t[name] = love.graphics.newImage(path)
		elseif love.filesystem.getInfo(path).type == 'directory' then
			t[file_name] = {}
			sprites.load(path, t[file_name])
		end
	end

	return t
end

local fetch = function(name)
	local images = sprites.sprites
	for n in string.gmatch(name, "[^%.]+") do
		if images[n] then
			images = images[n]
		else
			error('cannot find sprite: ' .. name)
		end
	end
	return images
end

function Sprite:new(name, t)
	t = t or {}
	self.image = fetch(name)

	self.width, self.height = self.image:getPixelDimensions()
	if t.no_center then
		self.off = V(0, 0)
	else
		self.off = V(self.width / 2, self.height / 2)
	end
end

function Sprite:draw(x, y)
	love.graphics.draw(self.image, math.floor(x + 0.5 - self.off.x), math.floor(y + 0.5 - self.off.y))
end

return Sprite