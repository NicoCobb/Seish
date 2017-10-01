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

	self.sMax = 1
	self.sMin = .3

	self.maxSpeed = speed or 50
	self.minSpeed = 10
	self.color = color or {255, 0, 0}
	self.animation = newAnimation(love.graphics.newImage('art_assets/Projeggtile.png'), 40, 40, .5, 5)
	self.active = true
	self.maxAttack = 50 -- the fully charged damage to an enemy.
	self.minAttack = 5

	self.speed = self.maxSpeed * (1 - self.charge) -- set bullet speed
	if self.speed < self.minSpeed then
		self.speed = self.minSpeed
	end

	self.scale = self.sMin
	self.scale = self.charge --set bullet size
	if self.scale < self.sMin then
		self.scale = self.sMin
	end
	self.r = self.scale*20

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
	
	self.animation.currentTime = self.animation.currentTime + dt
	if self.animation.currentTime >= self.animation.duration then
		self.animation.currentTime = self.animation.currentTime - self.animation.duration
	end
	
	self.x = self.x + math.cos(self.f)*self.speed
	self.y = self.y + math.sin(self.f)*self.speed
	self.collider:moveTo(self.x, self.y)

	if self.x > love.graphics.getWidth() + self.r or self.x < -self.r then
		-- it's off screen, kill it!
		self.active = false
	elseif self.y > love.graphics.getWidth()+self.r or self.y < -self.r then
		self.active = false
	end
end

function Bullet:draw()
	local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
	love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y, self.f, self.scale, self.scale)	
end

