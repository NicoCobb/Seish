--[[
A simple zombielike enemy that walks towards the the location it's passed in a straight line
]]

Class = require "class"

Enemy = Class()

function Enemy:init(x, y, target)
	-- it will constantly walk towards target.x and target.y
	self.target = target
	self.x = x
	self.y = y
	self.width = 50
	self.height = 100
	self.color = {255, 0, 0}
	self.health = 100
	self.attack = 25 -- deals this amount of damage if it reaches the player
	self.speed = 200
end

function Enemy:update(dt)
	local f = math.atan2(self.target.y - self.y, self.target.x - self.x)
	self.x = self.x + math.cos(f)*self.speed * dt
	self.y = self.y + math.sin(f)*self.speed * dt
	self:checkCollideWithTarget()
end

function Enemy:draw()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
end

function Enemy:checkCollideWithTarget()
	-- checks if the enemy collides with its target and if so deals damage and dies
	if self.health > 0 then
		if rectangleCollisionCheck(self.target.x, self.target.y, self.target.width, self.target.height, self.x, self.y, self.width, self.height) then
			-- it hit the enemy
			self.target.health = math.max(0, self.target.health - self.attack)
			self.health = 0
		end
	end
end