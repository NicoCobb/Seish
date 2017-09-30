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

Bullet = Class()

function Bullet:init(x, y, f, r, speed, color)
	self.x = x
	self.y = y
	self.f = f

	self.r = r or 10
	self.speed = speed or 50
	self.color = color or {255, 0, 0}
	self.active = true
	self.attack = 50 -- the amount of damage to do to an enemy.
end

function Bullet:update(dt)
	self.x = self.x + math.cos(self.f)*self.speed
	self.y = self.y + math.sin(self.f)*self.speed
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

function Bullet:checkEnemyCollision(enemy)
	-- pass in an enemy and handle it if it collides
	if self.active then
		-- it may not be active because it may have hit another enemy earlier in the loop
		if rectangleCollisionCheck(enemy.x, enemy.y, enemy.width, enemy.height, self.x, self.y, 2*self.r, 2*self.r) then
			-- that isn't a good way to do circle/rectangle collision, but it works for our purposes
			enemy.health = math.max(0, enemy.health - self.attack)
			self.active = false
		end
	end
end