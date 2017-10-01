--[[
	Pepper
	Moves randomly
--]]

Class = require "class"
require "enemy"

Pepper = Class{__includes = Enemy}

function Pepper:init(x, y, target)
	self.x = x
	self.y = y
	self.target = target
	self.width = 50
	self.height = 100
	self.speed = 150
	self.attack = 25
	self.health = 100
	self.color = {0, 0, 255}
	self.rX = math.random(1, 360)
	self.rY = math.random(1, 360)
	self.moveCooldown = 1
	end
	
function Pepper:update(dt)
	self.x = self.x + math.cos(math.rad(self.rX))*self.speed*dt
	self.y = self.y + math.sin(math.rad(self.rY))*self.speed*dt
	if self.moveCooldown <= 0 then
		self.rX = math.random(1, 360)
		self.rY = math.random(1, 360)
		self.moveCooldown = 1
		end
	if self.moveCooldown > 0 then
		self.moveCooldown = self.moveCooldown - dt
		end
	self:checkCollideWithTarget()
	end