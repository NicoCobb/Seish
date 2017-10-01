--[[
	Ketchup bullet class
	Contains projectiles shot by the ketchup enemy
--]]

Class = require "class"

Ketchup_bullet = Class()

function Ketchup_bullet:init(x, y, f, r, speed, color)
	self.x = x
	self.y = y
	self.f = f
	self.animation = newAnimation(love.graphics.newImage('art_assets/KetchupBlobule.png'), 40, 40, .5, 5)

	self.r = r or 10
	self.speed = speed or 50
	self.color = color or {255, 0, 0}
	self.active = true
	self.attack = 5 -- the amount of damage to do to an enemy.
end

function Ketchup_bullet:update(dt)

	self.animation.currentTime = self.animation.currentTime + dt
	if self.animation.currentTime >= self.animation.duration then
		self.animation.currentTime = self.animation.currentTime - self.animation.duration
	end
	
	self.x = self.x + math.cos(self.f)*self.speed
	self.y = self.y + math.sin(self.f)*self.speed
	if self.x > love.graphics.getWidth() + self.r or self.x < -self.r then
		-- it's off screen, kill it!
		self.active = false
	elseif self.y > love.graphics.getWidth() + self.r or self.y < -self.r then
		self.active = false
	end
end

function Ketchup_bullet:draw()
	local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
	love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y)	
end

function Ketchup_bullet:checkEnemyCollision(enemy)
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