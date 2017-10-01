--[[
	Ketchup
	Shoots projectiles at the player, doesn't move
--]]

Class = require "class"
require "enemy"
require "ketchup_bullet"
require "colliderType"

Ketchup = Class{__includes = {Enemy, ColliderType}}

function Ketchup:init(x, y, target)
	ColliderType.init(self, "enemy")
	self.x = 1000
	self.y = 600
	self.target = target
	self.health = 75
	self.height = 100
	self.width = 66
	self.color = {225, 30, 0}
	self.attack = 10

	self.animation = newAnimation(love.graphics.newImage('art_assets/CatchUpBlobShot.png'), 66, 100, .4, 2)

	self.cooldown = .3

	self.collider = HC.rectangle(0, 0, 50, 75)
	self.collider:moveTo(self.x, self.y)
	self.collider.colType = "enemy"
	self.collider.parent = self
end
	
function Ketchup:update(dt)
	
	self.animation.currentTime = self.animation.currentTime + dt
	if self.animation.currentTime >= self.animation.duration then
		self.animation.currentTime = self.animation.currentTime - self.animation.duration
	end
	
	self.cooldown = self.cooldown - dt
	
	self.collider:moveTo(self.x, self.y)
	--Loads enemy bullet aimed at the player
	local f = math.atan2(self.target.y - self.y, self.target.x - self.x)
	if self.cooldown <= 0 then
		local b = Ketchup_bullet(self.x-28, self.y-40, f, 10, 5, {128, 30, 30}) 

		addEnemyBullet(b)
		self.cooldown = .4
	end
end

function Ketchup:draw()
	local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
	love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y, math.atan2(self.target.y-self.y, self.target.x-self.x)+math.pi/2, 1, 1, 33,50)	
end
