local WorldState = require 'WorldState'
local LoadState = WorldState:extend()

function LoadState:new(World)

end

function LoadState:send()
	local datagram = serpent.dump(self.data)

	net.send_tcp(self.data)
end

return LoadState