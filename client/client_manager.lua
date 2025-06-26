local C = {}

function C.load()
	C.clients = {}
end

function C.add(client)
	table.insert(C.clients, client)
	print('adding client: ' .. client.address)
end

function C.get(address)
	for _, client in ipairs(C.clients) do
		if client.address == address then
			return client
		end
	end
end

return C