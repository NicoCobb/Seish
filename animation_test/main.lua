--Test folder for animations

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

function newOddAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
	
	table.remove(animation.quads)
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

function love.load()
	animation = newOddAnimation(love.graphics.newImage('egg/EggcelentSprite.png'), 50, 50, .75)
end

function love.update(dt)
	animation.currentTime = animation.currentTime + dt
	if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
	end
end

function love.draw()
	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum])
end