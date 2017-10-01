--[[
This is a simple game made with LOVE2D meant to teach some of the basics of the language
It has some obvious problems, but it's not meant to be perfect. Try fixing them!



This is the main.lua file.
Every love2d project must have one, otherwise it just won't work.
Most of the functions in this file (all of the ones that look like love.[function name] ) are Love2D callback functions.
The Love framework calls those functions when certain conditions are met, i.e. when the game first loads, when the framework
wants to draw everything to the screen, when a key is pressed on the keyboard, etc. The game code reacts to these callback functions
to handle everything it needs to do.
]]--

Camera = require "hump.camera"
require "player"
require "salt"
require "pepper"
require "ketchup"

--This enables us to create animations from spritesheets
function newAnimation(image, width, height, duration, extra)
    local extraQuad = extra or 0
	local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
	if extraQuad == 1 then
		table.remove(animation.quads)
    end
	animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

timeBetweenWaves = 5
waveCountdown = timeBetweenWaves
waveNumber = 0
maxWaveNumber = 0

player = Player()
enemies = {}
bullets = {}
enemy_bullets = {}
sprites = {}

function love.load(args)
	-- this function is run once when the game is launched, it's a good place to initialize your variables and
	-- load things like images or sounds
	love.window.setTitle("seish") -- name it whatever you want
	love.window.setMode(1200, 800)
	love.graphics.setBackgroundColor(50, 50, 50) -- sets the background color to be a uniform gray.
	-- Colors are represented by 0-255 values for red, green, blue and sometimes alpha
end

function love.update(dt)
	-- this function is run up to 60 fps and is used to handle all of the heavy lifting of the game
	-- the dt passed in is the delta time, which is the time since this function was last called, (use it for physics steps!)
	
	-- update the wave of zombies:
	if #enemies == 0 then
		-- if there are no enemies left, then count down the time until the next wave
		waveCountdown = waveCountdown - dt
	end
	if waveCountdown <= 0 then
		-- if it's time for the next wave, then update the wave number and spawn the enemies
		waveNumber = waveNumber + 1 -- it's the next wave
		maxWaveNumber = math.max(waveNumber, maxWaveNumber) -- if the player has reached a new high-score, update it!
		waveCountdown = timeBetweenWaves -- reset the timer until the next wave so that we're ready

		-- spawn the enemies in a circle around the center of the screen
		for i = 1, math.pow(2, waveNumber-1) do
			-- spawn enemies for the wave randomly in a circle
			local f = math.random() * 2 * math.pi
			local r = love.graphics.getWidth() + .25*love.graphics.getWidth()*math.random()
			local x = math.cos(f) * r + love.graphics.getWidth()/2
			local y = math.sin(f) * r + love.graphics.getHeight()/2
			table.insert(enemies, Ketchup(x, y, player))
		end
	end

	-- update the player, enemies and bullets
	-- if the enemies are dead or the bullets hit something then remove them from the tables
	player:update(dt)
	for i = #enemies, 1, -1 do
		-- this loop goes backwards through the list of enemies so that we can safely remove from the list without skipping any elements
		enemies[i]:update(dt)
		if enemies[i].health <= 0 then
			table.remove(enemies, i) -- remove dead enemies
		end
	end
	for i = #bullets, 1, -1 do
		bullets[i]:update(dt)
		for k, enemy in ipairs(enemies) do
			-- we have to check each bullet to see if it collided with an enemy
			bullets[i]:checkEnemyCollision(enemy)
		end
		if not bullets[i].active then
			table.remove(bullets, i) -- remove finished bullets
		end
	end
	
	for i = #enemy_bullets, 1, -1 do
		enemy_bullets[i]:update(dt)
		enemy_bullets[i]:checkEnemyCollision(player)
		if not enemy_bullets[i].active then
			table.remove(enemy_bullets, i)
		end
	end

	-- check if the player is dead, if so, reset everything:
	if player.health <= 0 then
		waveNumber = 0
		waveCountdown = timeBetweenWaves
		player.health = player.maxHealth
		enemies = {}
		bullets = {}
		enemy_bullets = {}
	end
end

function love.draw()
	-- this function is what is called to draw things to screen
	-- most of the calculations should have been done in love.update(dt), so this should be relatively quick to call

	-- draw the player, and draw all of the bullets and enemies
	
	player:draw()
	for k, v in ipairs(enemies) do
		v:draw()
	end
	for k, v in ipairs(bullets) do
		v:draw()
	end
	for k, v in ipairs(enemy_bullets) do
		v:draw()
	end
	-- then draw the HUD info
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf("Wave: "..waveNumber, 20, 20, 200)
	love.graphics.printf("Best: "..maxWaveNumber, 220, 20, 200)
	love.graphics.printf("Enemies left: "..#enemies, 420, 20, 200)
end

function love.keypressed(key, unicode)
	-- this is called whenever a key is pressed, it passes in the key and its unicode value

	-- if the escape key is pressed, quit the game
	if key == "escape" then
		love.event.quit()
	end
end

function love.mousereleased( x, y, button, istouch )
	player.charge = player.chargeIncrease / player.chargeTime --charge % calculation

	local f = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x) -- get the angle between the mouse and the player
	local b = Bullet(player.x, player.y, f, player.charge)

	addBullet(b)


	player.health = player.health - (player.charge * player.maxHealth * player.maxHealthUsed) --health is also ammo

	player.chargeIncrease = 0
	player.speed = player.maxSpeed

end

function addBullet(b)
	-- this function is used when the player fires a bullet to make it clearer what's happening
	table.insert(bullets, b)
end

function addEnemyBullet(b)
	table.insert(enemy_bullets, b)
end

function rectangleCollisionCheck(x1, y1, w1, h1, x2, y2, w2, h2)
	-- a general rectangle collision check:
	-- returns whether the two rectangles are touching
	-- the x and y coordinates in this case are the centers of the rectangles
	if x1 + w1/2 > x2 - w2/2 and x1 - w1/2 < x2 + w2/2 then
		if y1 + h1/2 > y2 - h2/2 and y1 - h1/2 < y2 + h2/2 then
			return true -- they're colliding
		end
	end
	return false
end