--[[	
	Enemy Salt AI
	Move towards the player in a straight line
--]]

Class = require "class"
require "enemy"

Salt = Class{__includes = Enemy}

--Initialize salt enemy, just moves at the player
function Salt:init(x, y, target)
	self.target = target
	self.x = x
	self.y = y
	self.width = 50
	self.height = 100
	self.color = {255, 255, 255}
	self.health = 100
	self.attack = 25
	self.speed = 150
	end
	