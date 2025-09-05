local s = {}

function s:post_load()
	self.super.post_load(self)

	self.shoot_delay = 0.1
	self.projectile_speed = 1000
	self.projectile_damage = 2
end

function s:main_attack(world)
	-- print('blue used main attack')
	self:shoot(world)
end

return s