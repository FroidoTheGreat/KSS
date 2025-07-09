local V = require 'Vector'
local physics = {}

local MAX_ITERATIONS = 5
local EPSILON = 0.001

function physics.load(object, settings)
	settings = settings or {}

	object.hitbox_radius = settings.radius or 20
	object.collision_type = settings.collision_type or 'slide'
	object.bounce_damping = settings.bounce_damping or 1
end

function physics.move(object, vel, world)
	local borders = world.map.borders

	local num_collisions = 0

	local total_movement_portion = 0
	local iteration = 0
	while (total_movement_portion < 1) and (iteration < MAX_ITERATIONS) do
		local collision, t, A, B, normal = physics.find_first_wall(object, vel, borders)

		if collision then
			num_collisions = num_collisions + 1

			t = math.max((t - EPSILON), 0)
			object.pos = object.pos + vel * t

			if object.collision_type == 'slide' then
				vel = vel - normal * (vel * normal)
				vel = vel * (1 - t)
			elseif object.collision_type == 'bounce' then
				vel = (vel - normal * 2 * (vel * normal)) * object.bounce_damping
				if object.vel then
					object.vel = object.vel - normal * 2 * (object.vel * normal)
					object.vel = object.vel * object.bounce_damping
				end
			end
		else
			object.pos = object.pos + vel * (1 - total_movement_portion)
			iteration = MAX_ITERATIONS
		end

		iteration = iteration + 1
		total_movement_portion = total_movement_portion + t
	end

	if num_collisions > 0 and type(object.wall) == 'function' then
		object:wall(num_collisions)
	end
end

function physics.find_first_wall(object, vel, borders)
	local min_t = 1
	local min_A, min_B, min_normal
	local has_collision
	local A, B
	local collision, t, normal
	for _, curve in ipairs(borders) do
		for i = 1, #curve do
			A = V(curve[i].x, curve[i].y)
			if i < #curve then
				-- check the line
				B = V(curve[i + 1].x, curve[i + 1].y)

				collision, t, normal = physics.check_line_collision(object, vel, A, B)
				if collision and t < min_t then
					min_t = t
					min_A = A
					min_B = B
					min_normal = normal
					has_collision = true
				end
			end

			-- check the endpoint
			collision, t, normal = physics.check_point_collision(object, vel, A)
			if collision and t < min_t then
				min_t = t
				min_A = A
				min_B = B
				min_normal = normal
				has_collision = true
			end
		end
	end
	return has_collision, min_t, min_A, min_B, min_normal
end

function physics.check_point_collision(object, vel, A)
	local C0 = object.pos
	local r = object.hitbox_radius

	local D = C0 - A

	local a = vel:mag2()
	local b = 2 * (D * vel)
	local c = D:mag2() - r * r

	local discriminant = b * b - 4 * a * c
	if discriminant < 0 then
		return false, 1
	end

	local sqrt_disc = math.sqrt(discriminant)
	local t1 = (-b - sqrt_disc) / (2 * a)
	local t2 = (-b + sqrt_disc) / (2 * a)

	local t = math.min(t1, t2)
	if t < 0 or t >= 1 then
		return false, 1
	end

	local contact_point = C0 + vel * t
	local normal = (contact_point - A):normal()

	return true, t, normal
end

function physics.check_line_collision(object, vel, A, B)
	local AB = B - A
	local normal = V(-AB.y, AB.x):normal()
	local dot = normal * vel
	if dot == 0 then
		return false, 1 -- no collision because movement is parallel to line
	elseif dot > 0 then
		normal = -normal
	end

	local d = (object.pos - A) * normal -- initial signed distance
	local v_n = vel * normal -- component of object velocity towards the line
	local t = (d - object.hitbox_radius) / (-v_n) -- time till collision

	if t < 0 or t >= 1 then
		return false, 1
	end

	local AB_length = AB:magnitude() -- FIXME: don't divide by zero I guess
	local P = object.pos + vel * t -- contact point
	local AP = P - A
	local proj = AP * (AB / AB_length)

	if proj < 0 or proj > AB_length then
		return false, 1
	end

	return true, t, normal
end

return physics