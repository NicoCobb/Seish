--[[
Problems with this class:
Collision checking just pretends the bullet is a rectangle, 
I've deemed it good enough, since it's likely these bullets will only be used against enemies.

Things to try adding:
Change the speed, size and color!
Randomize the bullet spray somewhat so that the game feels more exciting!
Make enemies that fire bullets at the player!
]]--

Class = require "class"
require "ColliderType"

Bullet = Class{__includes = ColliderType}

function Bullet:init(x, y, f, charge, r, speed, color)
	ColliderType.init(self, "playerBullet")
	self.x = x
	self.y = y
	self.f = f
	self.charge = charge

	self.rMax = 30
	self.rMin = 10
	self.maxSpeed = speed or 50
	self.minSpeed = 10
	self.color = color or {255, 0, 0}
	self.active = true
	self.maxAttack = 50 -- the fully charged damage to an enemy.
	self.minAttack = 5

	self.speed = self.maxSpeed * (1 - self.charge) -- set bullet speed
	if self.speed < self.minSpeed then
		self.speed = self.minSpeed
	end

	self.r = self.rMax * self.charge --set bullet size
	if self.r < self.rMin then
		self.r = self.rMin
	end

	self.attack = self.maxAttack * self.charge --set bullet attack value
	if self.attack < self.minAttack then
		self.attack = self.minAttack
	end

	self.collider = HC.circle(0, 0, 30)
	self.collider:moveTo(self.x, self.y)
	self.collider.colType = "playerBullet"
	self.collider.parent = self
end

function Bullet:update(dt)
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

function Bullet:draw()
	love.graphics.setColor(self.color)
	love.graphics.ellipse("fill", self.x, self.y, self.r, self.r)
end