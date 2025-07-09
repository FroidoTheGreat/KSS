local serpent = require 'serpent'
local Color = require 'Color'
local Canvas = require 'Canvas'
local Sprite = require 'Sprite'
local Camera = require 'Camera'
local sprites = Sprite.sprites
sprites.load()

local render = {}

local clear_color
local canvas

function render.load()
	clear_color = Color('36363d')
	canvas = Canvas(400, 400)

	render.camera = Camera(canvas)

	-- bubbles
	render.bubbles = {}
	local max = 1000
	local num_bubbles = 500
	render.bubble_sprite = Sprite('bubbles')

	for i = 1, num_bubbles do
		table.insert(render.bubbles, {
			x = (math.random() * max * 2) - max,
			y = (math.random() * max * 2) - max,
			depth = math.random() / 2 + 0.1,
			size = math.floor((math.random() * 5)) + 1,
		})
	end
end

function render.update(dt, world)
	if world.me then
		render.camera:follow(dt, world.me, 5)
	end
end

function render.draw(world)
	canvas:set()

	clear_color:clear()

	-- draw bubbles

	for _, bubble in ipairs(render.bubbles) do
		love.graphics.push()
		render.camera:apply(bubble.depth)
		render.bubble_sprite:draw(bubble.x, bubble.y, bubble.size)
		love.graphics.pop()
	end

	-- draw world

	love.graphics.push()
	render.camera:apply()

	for _, object in pairs(world.items) do
		if type(object.draw) == 'function' then
			object:draw()
		end
	end

	-- draw boundaries

	love.graphics.push()
	Color(255, 255, 255):set()
	love.graphics.setLineWidth(10)
	love.graphics.setLineStyle('rough')

	local map = world.map

	for _, curve in ipairs(map.borders) do
		for i=1, #curve do
			local A = curve[i]
			if i < #curve then
				local B = curve[i+1]
				love.graphics.line(A.x, A.y, B.x, B.y)
			end

			love.graphics.circle('fill', A.x, A.y, 5)
		end
	end

	love.graphics.pop()

	--[[ draw mouse pointer

	local C = require 'controller'
	if world.me then
		love.graphics.push()
		Color(255, 20, 20):set()
		love.graphics.circle('fill', C.mouse_p.x, C.mouse_p.y, 10)
		love.graphics.pop()
	end]]

	love.graphics.pop()

	canvas:draw(100, 0, 1.5)
end

function render.getOffset()
	return 100 - render.camera.pos.x * 1.5, -render.camera.pos.y * 1.5, 1.5
end

return render