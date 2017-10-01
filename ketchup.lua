--[[
	Ketchup
	Shoots projectiles at the player, doesn't move
--]]

Class = require "class"
require "enemy"
require "ketchup_bullet"

Ketchup = Class{__includes = Enemy}

function Ketchup:init(x, y, target)
	self.x = 1000
	self.y = 600
	self.target = target
	self.health = 75
	self.height = 100
	self.width = 50
	self.color = {225, 30, 0}
	self.attack = 0
		
	self.cooldown = .3
end
	
function Ketchup:update(dt)
	self.cooldown = self.cooldown - dt
	
	--Loads enemy bullet aimed at the player
	local f = math.atan2(self.target.y - self.y, self.target.x - self.x)
	if self.cooldown <= 0 then
		local b = Ketchup_bullet(self.x, self.y, f, 5, 5, {128, 30, 30}) 
		addEnemyBullet(b)
		self.cooldown = 1
	end
	self:checkCollideWithTarget()
end