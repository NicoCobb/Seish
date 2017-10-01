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
HC = require "HC"

timeBetweenWaves = 5
waveCountdown = timeBetweenWaves
waveNumber = 0
maxWaveNumber = 0
kitchen = love.graphics.newImage("art_assets/Kitchen.png")

player = Player()
enemies = {}
bullets = {}
enemy_bullets = {}
objects = {}
text = {}

function love.load(args)
	-- this function is run once when the game is launched, it's a good place to initialize your variables and
	-- load things like images or sounds
	love.window.setTitle("seish") -- name it whatever you want
	love.window.setMode(1200,800)

	--love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
	kHeight = kitchen:getHeight()
	kWidth = kitchen:getWidth()
	love.graphics.draw( kitchen, 0, 0, 0, 1, 1)
	-- Colors are represented by 0-255 values for red, green, blue and sometimes alpha

	--create border
	borderTop    = HC.rectangle(0,-100, 1200,100)
	borderTop.colType = "object"
	table.insert(objects, borderTop)
    borderBottom = HC.rectangle(0,800, 1200,100)
    borderBottom.colType = "object"
    table.insert(objects, borderBottom)
    boarderLeft     = HC.rectangle(-100,0, 100,800)
    boarderLeft.colType = "object"
    table.insert(objects, borderLeft)
    boarderRight    = HC.rectangle(1200,0, 100,800)
    boarderRight.colType = "object"
    table.insert(objects, borderRight)
    bigWall 	= HC.rectangle(600, 0, 50, 800)
    bigWall.colType = "object"
    table.insert(objects, bigWall)
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

	-- check collisions for player
	local playerCollisions = HC.collisions(player.collider)
    for other, separating_vector in pairs(playerCollisions) do

    	if other.colType == "object" then
    		player.x = player.x + separating_vector.x
    		player.y = player.y + separating_vector.y
    	elseif other.colType == "enemyBullet" then
    		player.health = player.health - other.parent.attack
    		other.parent.active = false
    	elseif other.colType == "enemy" then
    		player.health = player.health - other.parent.attack
    		other.parent.health = 0
    	end
    end

    -- check for if bullets collide with objects and deactivate
    for i = #objects, 1, -1 do
    	local objectCollisions = HC.collisions(objects[i])
    	for other, separating_vector in pairs(objectCollisions) do

    		if other.colType == "enemyBullet" or other.colType == "playerBullet" then
    			other.parent.active = false
    		end
    	end
    end

    -- check for if bullets hit enemies and damage + deactivate bullet
    for i = #enemies, 1, -1 do
    	local enemyCollisions = HC.collisions(enemies[i].collider)
    	for other, separating_vector in pairs(enemyCollisions) do

    		if other.colType == "playerBullet" then
    			enemies[i].health = enemies[i].health - other.parent.attack
    			other.parent.active = false
    		end
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

		if not bullets[i].active then
			table.remove(bullets, i) -- remove finished bullets
		end
	end
	
	for i = #enemy_bullets, 1, -1 do
		enemy_bullets[i]:update(dt)

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

	--draw the background
	love.graphics.setColor(255,255,255)
	love.graphics.draw( kitchen, 0, 0, 0, 1, 1)

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

	love.graphics.setColor(255,255,255)
	love.graphics.printf("Wave: "..waveNumber, 20, 20, 200)
	love.graphics.printf("Best: "..maxWaveNumber, 220, 20, 200)
	love.graphics.printf("Enemies left: "..#enemies, 420, 20, 200)

	-- print messages
    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end
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