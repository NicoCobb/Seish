--[[
A simple player class that is controlled via keyboard and mouse

Some things you may want to try fixing:
- you walk faster diagonally than straight
- there's no way to determine what health you're at
- there's no way to determine whether your weapons are reloaded
]]--

Class = require "class"
require "bullet"

Player = Class()


function Player:init(health)
	self.maxHealth = 100
	self.health = self.maxHealth
	self.maxSpeed = 200
	self.minSpeed = 70
	self.speed = 200
	self.x = 0
	self.y = 0

	self.color = {200, 255, 100, 255} -- if you don't have the fourth number it defaults to 255 alpha
	self.width = 50
	self.height = 100

	self.charge = 0 -- % charge when firing the bullet
	self.chargeTime = 2 -- maximum charge time
	self.chargeIncrease = 0 -- used to count how long the bullet is being charged for
	self.maxHealthUsed = .1 -- amount of health that gets consumed on a max charge bullet
end

function Player:update(dt)
	local boolVal = {[true] = 1, [false] = 0}
	-- the square brackets around the boolean values signify that they are the keys
	-- for strings you could just type them in there like t = { hello = 5 }, but if you wanted it to start with a
	-- control character you may have to do the following: t = { [.weird] = false }


	-- handle movement:
	local dx = boolVal[love.keyboard.isDown("d")] - boolVal[love.keyboard.isDown("a")]
	local dy = boolVal[love.keyboard.isDown("s")] - boolVal[love.keyboard.isDown("w")]
	local dxAdjusted = dx
	local dyAdjusted = dy

	local magnitude = math.sqrt(dx^2 + dy^2)
	if magnitude ~= 0 then
		dxAdjusted = dx/magnitude
		dyAdjusted = dy/magnitude
	end

	self.x = self.x + dxAdjusted * self.speed * dt -- make sure you use dt (delta time) to ensure you move the same
	self.y = self.y + dyAdjusted * self.speed * dt -- speed no matter the framerate

	-- build up charge on bullet
	if love.mouse.isDown(1) then 
		if self.chargeIncrease < self.chargeTime then --charge up the bullet as long as the mouse is held or to max
			self.chargeIncrease = self.chargeIncrease + dt
		end

		self.speed = self.speed * .98
		if self.speed < self.minSpeed then
			self.speed = self.minSpeed
		end
	end
end

function Player:draw()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
end