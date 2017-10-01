--[[	
	Enemy Salt AI
	Move towards the player in a straight line
--]]

Class = require "class"
require "enemy"
require "colliderType"

Salt = Class{__includes = {Enemy, ColliderType}}

--Initialize salt enemy, just moves at the player
function Salt:init(x, y, target)
	ColliderType.init(self, "enemy")
	self.colType = "enemy"
	self.target = target
	self.x = x
	self.y = y
	self.width = 44
	self.height = 75
	self.color = {255, 255, 255}
	self.health = 100
	self.attack = 25
	self.speed = 100
	self.animation = newAnimation(love.graphics.newImage('art_assets/AsaltinatorSprite.png'), 44, 75, .75, 2)

	self.collider = HC.rectangle(0, 0, 44, 75)
	self.collider:moveTo(self.x + self.x/2, self.y + self.y/2)
	self.collider.colType = "enemy"
	self.collider.parent = self

end
	
function Salt:update(dt)
	self.collider:moveTo(self.x + self.width/2, self.y + self.height/2)
	self.animation.currentTime = self.animation.currentTime + dt
	if self.animation.currentTime >= self.animation.duration then
		self.animation.currentTime = self.animation.currentTime - self.animation.duration
	end
	
	local f = math.atan2(self.target.y - self.y, self.target.x - self.x)
	self.x = self.x + math.cos(f)*self.speed * dt
	self.y = self.y + math.sin(f)*self.speed * dt
end
	
function Salt:draw()
	local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
	love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y)	
	self.collider:draw(fill)
end
