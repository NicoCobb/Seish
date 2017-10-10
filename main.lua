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
HC = require "HC"
Gamestate = require "hump.gamestate"

require "player"
require "salt"
require "pepper"
require "ketchup"

--This enables us to create animations from spritesheets
function newAnimation(image, width, height, duration, extra)
    local extraQuad = extra or 0
	local animation = {}
    animation.spriteSheet = image
    animation.quads = {}
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
	for n = 0, extraQuad, 1 do
		table.remove(animation.quads)
    end
	animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

numRooms = math.random(3, 5)
roomCount = 0

local menu = {}
local intro = {}
local game = {}
local last = {}
local endScreen = {}

player = Player()
enemies = {}
roomObjects = {}
bullets = {}
enemy_bullets = {}
objects = {}
text = {}
backgrounds = {love.graphics.newImage("art_assets/StartScreen1.png"), love.graphics.newImage("art_assets/Kitchen.png"),
			   love.graphics.newImage("art_assets/Room.png"),  love.graphics.newImage("art_assets/SleepingDude.png"),
			   love.graphics.newImage("art_assets/AwakeDude.png") } 

sTable = false
chair = false
lTable = false
couch = false

--Generate a room of enemies and objects at random
function loadRoom()

	enemyRNG1 = math.random(1, 4) --number of enemies
	objectRNG = math.random(0, 3) --number of randomly added 
	playerSpawnX = math.random(0, 200) --how far from the middle player.x will start
	playerSpawnY = math.random(0, 134) --how far from the middle player.y will start
	roomCount = roomCount + 1
	
	--Chooses the type and position of the objects
	for n = objectRNG, 1, -1 do
		whichObject = math.random(1, 4)
		if whichObject == 1 then
			--Small table
			love.graphics.draw("art_assets/LittleTable.png", math.random(100, 800), math.random(100, 450))
		elseif whichObject == 2 then
			--Chair
			love.graphics.draw("art_assets/Chair.png", math.random(100, 800), math.random(100, 450))
		elseif whichObject == 3 then
			--Large table
			love.graphics.draw("art_assets/LargeTable.png", math.random(100, 550), math.random(100, 400))
		elseif whichObject == 4 then
			--Couch
			love.graphics.draw("art_assets/Couch.png", math.random(100, 550), math.random(100, 400))
		end
	end
	
	--Decides which enemies to place and where
	for n = enemyRNG1, 1, -1 do
		whichEnemy = math.random(1, 3)
		if whichEnemy == 1 then
			table.insert(enemies, Salt(math.random(100, 800), math.random(0, 1100), player))
		elseif whichEnemy == 2 then
			table.insert(enemies, Pepper(math.random(100, 800), math.random(0, 1100), player))
		elseif whichEnemy == 3 then
			table.insert(enemies, Ketchup(math.random(100, 800), math.random(0, 1100), player))
		end
	end
		
end

--Delete the room and load new room
function exitRoom()

	for a = #roomObjects, 1, -1 do
		table.remove(enemies, a)
	end
	for a = #bullets, 1, -1 do
		table.remove(bullets, a)
	end
	for a = #enemy_bullets, 1, -1 do
		table.remove(enemy_bullets, a)
	end
	if roomCount < numRooms then
		loadRoom()
	end
end

function love.load(args)
	-- this function is run once when the game is launched, it's a good place to initialize your variables and
	-- load things like images or sounds
    love.window.setTitle("seish") -- name it whatever you want
	love.window.setMode(1200,800)

	Gamestate.registerEvents()
    Gamestate.switch(menu)

	bgm = love.audio.newSource("Sounds/Pop_Goes_The_Weasel_Main.wav", "stream")
	love.audio.play(bgm)
end

function menu:enter()
	love.graphics.draw(backgrounds[1])
end

function menu:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(intro)
    end
end

function intro:enter()

	-- Colors are represented by 0-255 values for red, green, blue and sometimes alpha
	love.graphics.draw(backgrounds[2])

	--create border
	borderTop    = HC.rectangle(0,-120, 1200,100)
	borderTop.colType = "object"
	table.insert(objects, borderTop)
    borderBottom = HC.rectangle(0,780, 1200,100)
    borderBottom.colType = "object"
    table.insert(objects, borderBottom)
    boarderLeft     = HC.rectangle(-130,0, 100,800)
    boarderLeft.colType = "object"
    table.insert(objects, borderLeft)
    boarderRight    = HC.rectangle(1170,0, 100,800)
    boarderRight.colType = "object"
    table.insert(objects, borderRight)

    introDoor = HC.rectangle(1100, 500, 30, 180)
    introDoor:draw(fill)
    introDoor.colType = "door"

end

function menu:draw()
	love.graphics.draw(backgrounds[1])
end


function intro:update(dt)
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
    	elseif other.colType == "door" then
    		player.x = 100
    		player.y = 400
    		Gamestate.switch(game)
    	end
    end

    player:update(dt)
end

function game:update(dt)
	-- this function is run up to 60 fps and is used to handle all of the heavy lifting of the game
	-- the dt passed in is the delta time, which is the time since this function was last called, (use it for physics steps!)

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
    	elseif other.colType == "door" then
    		roomCount = roomCount + 1
    		exitRoom()
    	end
    end

    -- check for if bullets collide with objects and deactivate
    for i = #objects, 1, -1 do
    	local objectCollisions = HC.collisions(objects[i])
    	for other, separating_vector in pairs(objectCollisions) do

    		if other.colType == "enemyBullet" or other.colType == "playerBullet" then
    			other.parent.active = false
    		elseif other.colType == "enemy" then
    		other.parent.x = other.parent.x - separating_vector.x
    		other.parent.y = other.parent.y - separating_vector.y
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
		Gamestate.switch(menu)
	end
end

function intro:draw()
	--draw the background
	love.graphics.setColor(255,255,255)
	love.graphics.draw( backgrounds[2])

	--draw the player
	player:draw()
	introDoor:draw(fill)
end

function game:draw()
	-- this function is what is called to draw things to screen
	-- most of the calculations should have been done in love.update(dt), so this should be relatively quick to call

	--draw the background
	love.graphics.setColor(255,255,255)
	love.graphics.draw( backgrounds[3])

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
	love.graphics.printf("Enemies left: "..#enemies, 420, 20, 200)
	love.graphics.printf("Health:" ..player.health, 550, 20, 200)

end

function intro:mousereleased( x, y, button, istouch )
	player.charge = player.chargeIncrease / player.chargeTime --charge % calculation

	local f = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x) -- get the angle between the mouse and the player
	local b = Bullet(player.x, player.y, f, player.charge)

	addBullet(b)


	-- player.health = player.health - (player.charge * player.maxHealth * player.maxHealthUsed) --health is also ammo

	player.chargeIncrease = 0
	player.speed = player.maxSpeed
end

q = 2.1
countdown = 1
countdownCounter = 0
function last:update(dt)
	-- check collisions for player
	local playerCollisions = HC.collisions(player.collider)
	--Dude's position is not set
	dude = HC.rectangle(600, 100, 560, 190)
	dude.colType = "dude"
	dude.animation = newAnimation(love.graphics.newImage("art_assets/DustCloud.png"), 1200, 800, 1)
	
	dude.animation.currentTime = dude.animation.currentTime + dt
		if dude.animation.currentTime >= dude.animation.duration then
			dude.animation.currentTime = dude.animation.currentTime - dude.animation.duration
		end
	
	woke = false
	ded = false
	finish = false
	
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
		elseif other.colType == "dude" then
			woke = true
			ded = true
			q = q - dt
			if q <= .6 then
				ded = true
			end
			if q <= 0 then
				finish = true
			end
    	end

    	if woke then
    		countdownCounter = countdownCounter + dt
    	end

    	if countdownCounter > countdown then
    		Gamestate.switch(endScreen)
    	end

    end
	if finish then
	end	

    player:update(dt)
end

function last:draw()
	--draw the background
	love.graphics.setColor(255,255,255)
	if not woke then
		love.graphics.draw( backgrounds[4])
--[[	elseif ded then
		local spriteNum = math.floor(dude.animation.currentTime / dude.animation.duration * #dude.animation.quads) + 1
		love.graphics.draw(dude.animation.spriteSheet, dude.animation.quads[spriteNum], 1200, 800) ]]--
	elseif woke then
		love.graphics.draw( backgrounds[5])
	end

	if sTable then
		love.graphics.draw(love.graphics.newImage("art_assets/LittleTable.png"), sTx, sTy)
	end

	if lTable then
		love.graphics.draw(love.graphics.newImage("art_assets/LargeTable.png"), lTx, lTy)
	end

	if chair then
		love.graphics.draw(love.graphics.newImage("art_assets/LargeTable.png"), lTx, lTy)
	end 

	if couch then
		love.graphics.draw(love.graphics.newImage("art_assets/Couch.png"), cOx, cOy)
	end 
	--draw the player
	player:draw()
end

function last:enter()

	-- Colors are represented by 0-255 values for red, green, blue and sometimes alpha
	love.graphics.draw(backgrounds[4])

	--create border
	borderTop    = HC.rectangle(0,-120, 1200,100)
	borderTop.colType = "object"
	table.insert(objects, borderTop)
    borderBottom = HC.rectangle(0,780, 1200,100)
    borderBottom.colType = "object"
    table.insert(objects, borderBottom)
    boarderLeft     = HC.rectangle(-130,0, 100,800)
    boarderLeft.colType = "object"
    table.insert(objects, borderLeft)
    boarderRight    = HC.rectangle(1170,0, 100,800)
    boarderRight.colType = "object"
    table.insert(objects, borderRight)
	
end

function game:mousereleased( x, y, button, istouch )
	player.charge = player.chargeIncrease / player.chargeTime --charge % calculation

	local f = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x) -- get the angle between the mouse and the player
	local b = Bullet(player.x, player.y, f, player.charge)

	addBullet(b)


	--player.health = player.health - (player.charge * player.maxHealth * player.maxHealthUsed) --health is also ammo

	player.chargeIncrease = 0
	player.speed = player.maxSpeed
end

function love.keypressed(key, unicode)
	-- this is called whenever a key is pressed, it passes in the key and its unicode value

	-- if the escape key is pressed, quit the game
	if key == "escape" then
		love.event.quit()
	end
end

function addBullet(b)
	-- this function is used when the player fires a bullet to make it clearer what's happening
	table.insert(bullets, b)
end

function addEnemyBullet(b)
	table.insert(enemy_bullets, b)
end

sTx = 0
sTy = 0

cHx = 0
cHy = 0

lTx = 0
lTy = 0

cOx = 0
cOy = 0
function loadRoom()

	enemyRNG1 = math.random(1, 5) --number of enemies
	objectRNG = math.random(1, 3) --number of randomly added 
	player.x = 100 --spawn at door
	player.y = 400 
	roomCount = roomCount + 1
	
	--Chooses the type and position of the objects
	for n = objectRNG, 1, -1 do
		whichObject = math.random(1, 4)
		if whichObject == 1 then
			--Small table
			sTable = true
			sTx = math.random(100, 800)
			sTy = math.random(100, 450)
			love.graphics.draw(love.graphics.newImage("art_assets/LittleTable.png"), sTx, sTy)
		elseif whichObject == 2 then
			--Chair
			chair = true
			cHx = math.random(100, 800)
			cHy = math.random(100, 450)
			love.graphics.draw(love.graphics.newImage("art_assets/Chair.png"), cHx, cHy)
		elseif whichObject == 3 then
			--Large table
			lTable = true
			lTx = math.random(100, 550)
			lTy = math.random(100, 400)
			love.graphics.draw(love.graphics.newImage("art_assets/LargeTable.png"), lTx, lTy)
		elseif whichObject == 4 then
			--Couch
			couch = true
			cOx = math.random(100, 550)
			cOy = math.random(100, 400)
			love.graphics.draw(love.graphics.newImage("art_assets/Couch.png"), cOx, cOy)
		end
	end
	
	--Decides which enemies to place and where
	for n = enemyRNG1, 1, -1 do
		whichEnemy = math.random(1, 3)
		if whichEnemy == 1 then
			table.insert(enemies, Salt(math.random(130, 800), math.random(0, 1100), player))
		elseif whichEnemy == 2 then
			table.insert(enemies, Pepper(math.random(130, 800), math.random(0, 1100), player))
		elseif whichEnemy == 3 then
			table.insert(enemies, Ketchup(math.random(130, 800), math.random(0, 1100), player))
		end
	end
		
end


function game:load()
	doorRight = HC.rectangle(1050, 750, 20, 100)
	doorRight.colType = "door"
	doorRight:draw(fill)

	loadRoom()
end

function endScreen:load()
	love.graphics.draw(love.graphics.newImage("art_assets/End_Screen.png"))
end

function endScreen:draw()
	love.graphics.draw(love.graphics.newImage("art_assets/End_Screen.png"))
end

function endScreen:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(menu)
    end
end

--Delete the room and load new room
function exitRoom()

	for a = #roomObjects, 1, -1 do
		table.remove(enemies, a)
	end

	for a = #bullets, 1, -1 do
		table.remove(bullets, a)
	end

	for a = #enemy_bullets, 1, -1 do
		table.remove(enemy_bullets, a)
	end

	sTx = 0
	sTy = 0

	cHx = 0
	cHy = 0

	lTx = 0
	lTy = 0

	cOx = 0
	cOy = 0

	sTable = false
	chair = false
	lTable = false
	couch = false

	if roomCount < numRooms then
		loadRoom()
	else
		player.x = 100
		player.y = 400
		Gamestate.switch(last)
	end
end