--[[
	Pepper
	Moves randomly
--]]

require "enemy"
require "class"

Pepper = Class{__include = Enemy}

function Pepper:init(x, y)
	self.x = x
	self.y = y
	self.width = 50
	self.height = 100
	self.speed = 150
	self.attack = 25
	self.health = 100
	self.color = {0, 0, 255}
	end
	
function Pepper:update(dt)
	
	end