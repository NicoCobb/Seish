--[[
	Ketchup bullet class
	Contains projectiles shot by the ketchup enemy
--]]

Class = require "class"
require "ColliderType"

Ketchup_bullet = Class{__includes = ColliderType}

function Ketchup_bullet:init(x, y, f, r, speed, color)
	ColliderType.init(self, "enemyBullet")
	self.x = x
	self.y = y
	self.f = f

	self.r = r or 10
	self.speed = speed or 50
	self.color = color or {255, 0, 0}
	self.active = true
	self.attack = 5 -- the amount of damage to do to an enemy.

	self.collider = HC.circle(0, 0, 5)
	self.collider:moveTo(self.x, self.y)
	self.collider.colType = "enemyBullet"
	self.collider.parent = self
end

function Ketchup_bullet:update(dt)
	self.x = self.x + math.cos(self.f)*self.speed
	self.y = self.y + math.sin(self.f)*self.speed

	self.collider:moveTo(self.x, self.y)

	if self.x > love.graphics.getWidth() + self.r or self.x < -self.r then
		-- it's off screen, kill it!
		self.active = false
	elseif self.y > love.graphics.getWidth() + self.r or self.y < -self.r then
		self.active = false
	end
end

function Ketchup_bullet:draw()
	love.graphics.setColor(self.color)
	love.graphics.ellipse("fill", self.x, self.y, self.r, self.r)
end