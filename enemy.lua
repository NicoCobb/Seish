--[[
A simple zombielike enemy that walks towards the the location it's passed in a straight line
]]

Class = require "class"
require "colliderType"

Enemy = Class{__includes = ColliderType}

function Enemy:init(x, y, target)
	-- it will constantly walk towards target.x and target.y
	ColliderType.init(self, "enemy")
	self.target = target
	self.x = x
	self.y = y
	self.width = 50
	self.height = 100
	self.color = {255, 0, 0}
	self.health = 100
	self.attack = 25 -- deals this amount of damage if it reaches the player
	self.speed = 200

	self.collider = HC.rectangle(0, 0, 50, 75)
	self.collider:moveTo(self.x, self.y)
	self.collider.colType = "enemy"
	self.collider.parent = self
end

function Enemy:update(dt)
	self.collider:moveTo(self.x, self.y)

	local f = math.atan2(self.target.y - self.y, self.target.x - self.x)
	self.x = self.x + math.cos(f)*self.speed * dt
	self.y = self.y + math.sin(f)*self.speed * dt
end

function Enemy:draw()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
end