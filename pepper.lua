--[[
	Pepper
	Moves randomly
--]]

Class = require "class"
require "enemy"
require "colliderType"

Pepper = Class{__includes = {Enemy, ColliderType}}

function Pepper:init(x, y, target)
	ColliderType.init(self, "enemy")
	self.colType = "enemy"
	self.x = x
	self.y = y
	self.target = target
	self.width = 50
	self.height = 100
	self.speed = 150
	self.attack = 25
	self.health = 100
	--Blue
	self.color = {0, 0, 255}
	self.animation = newAnimation(love.graphics.newImage('art_assets/PepperificSprite.png'), 50, 100, .75, 2)
	self.rX = math.random(1, 360)
	self.rY = math.random(1, 360)
	--How often it changes direction
	self.moveCooldown = 1
	self.collider = HC.rectangle(0, 0, 50, 100)
	self.collider:moveTo(self.x, self.y)
	self.collider.colType = "enemy"
	self.collider.parent = self
end

function Pepper:update(dt)
	self.animation.currentTime = self.animation.currentTime + dt
	if self.animation.currentTime >= self.animation.duration then
		self.animation.currentTime = self.animation.currentTime - self.animation.duration
	end

	self.collider:moveTo(self.x, self.y)

	--It moves in the predetermined random direction/speed
	self.x = self.x + math.cos(math.rad(self.rX))*self.speed*dt
	self.y = self.y + math.sin(math.rad(self.rY))*self.speed*dt
	if self.moveCooldown <= 0 then
		--After 1 second, it picks a new direction/speed at random
		self.rX = math.random(1, 360)
		self.rY = math.random(1, 360)
		self.moveCooldown = 1
	end
	if self.moveCooldown > 0 then
		self.moveCooldown = self.moveCooldown - dt
	end
end

function Pepper:draw()
	local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
	love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y)	
end
