local s = {}

function s:post_load()
	self.super.post_load(self)

	self.shoot_delay = 0.3
	self.projectile_speed = 600
	self.projectile_damage = 15
end

function s:main_attack(world)
	-- print('green used main attack')
	self:shoot(world)
end

return s