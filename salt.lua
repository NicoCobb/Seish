--[[	
	Enemy Salt AI
	Move towards the player in a straight line
--]]

Class = require "class"
require "enemy"
require "colliderType"

Salt = Class{__includes = {Enemy, ColliderType}}

--Initialize salt enemy, just moves at the player
function Salt:init(x, y, target)
	ColliderType.init(self, "enemy")
	self.colType = "enemy"
	self.target = target
	self.x = x
	self.y = y
	self.width = 50
	self.height = 100
	self.color = {255, 255, 255}
	self.health = 100
	self.attack = 25
	self.speed = 150

	self.collider = HC.rectangle(0, 0, 50, 100)
	self.collider:moveTo(self.x, self.y)
	self.collider.colType = "enemy"
	self.collider.parent = self
	end
	