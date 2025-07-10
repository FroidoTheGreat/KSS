local t = {}

t.to_alias = {
	-- basics
	typ = 'T',
	purge = 'X',
	pos = 'P',
	vel = 'V',
	life = 'L',

	-- player
	name = 'N',

	-- boss
	stage = 'S',
}

t.to_key = {}
for k, v in pairs(t.to_alias) do
	if t.to_key[v] then
		error(v..' already has meaning '..t.to_key[v]..' so cannot add meaning '..k)
	end
	t.to_key[v] = k
end

return t