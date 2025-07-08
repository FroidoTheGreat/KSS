local Color = require 'Color'
local Canvas = require 'Canvas'
local Sprite = require 'Sprite'
local sprites = Sprite.sprites
sprites.load()

local render = {}

local plr = Sprite('chars.gold')

local clear_color = Color('36363d')
local canvas = Canvas(400, 400)
local bg = Sprite('backgrounds.1', {
	no_center = true
})

function render.draw(world)
	canvas:set()

	clear_color:clear()

	bg:draw(0, 0)

	for _, object in pairs(world.items) do
		if type(object.draw) == 'function' then
			object:draw()
		end
	end

	canvas:draw(100, 0, 1.5)
end

function render.getOffset()
	return 100, 0, 1.5
end

return render