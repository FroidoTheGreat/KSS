local objects = {}
local names = {
	'player',
	'projectile'
}

local map = {}

-- requires all files in the objects folder and adds the proper methods
function objects.load(typ)
	if type(typ) == 'string' and typ ~= 'server' and typ ~= 'client' then
		error('trying to load objects with non-server, non-client type')
	end
	typ = typ or 'client'
	print('loading objects from '..typ)
	for _, name in ipairs(names) do
		local prefix = 'objects/'..name..'/'
		map[name] = require(prefix..'shared')
		map[name].post_update = require(prefix..typ).post_update
		if typ == server then
			-- add server methods
		else
			-- add client methods
		end
	end
end

function objects.get(name)
	if not map[name] then
		return nil
	end
	return map[name]
end

return objects