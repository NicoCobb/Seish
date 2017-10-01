-- this will be inhereted by all classes who can collide

Class = require "class"

ColliderType = Class{
	init = function(self, collider)
        self.colType = collider
    end;
}
