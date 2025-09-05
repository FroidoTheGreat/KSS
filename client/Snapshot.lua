local Object = require 'Object'
local Snapshot = Object:extend()

function Snapshot:new(data, items, timestamp)
	self.data = {}
	self.timestamp = timestamp

	for _, v in ipairs(data) do -- FIXME: I really need to make updates follow the same
								-- convention of key=id

		local id = v.id
		self.data[id] = {
			pos = v.pos,
			vel = v.vel,
		}
	end

	-- where the update did not give information, use the world's information??
	-- but how do you know which world information to use?
	-- do you look at a snapshot? hmmmm
	for k, v in pairs(items) do
		local other = self.data[k]
		if not other then
			self.data[k] = {
				pos = v.pos,
				vel = v.vel,
			}
		else
			if not other.pos then other.pos = v.pos end
			if not other.vel then other.vel = v.vel end
		end
	end
end

function Snapshot:apply(world)
	-- uhh
end

return Snapshot