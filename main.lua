-- FatPoly - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Player = require("classes/Player")
local Food = require("classes/Food")
local SpecialEffect = require("classes/SpecialEffect")
local ParticleSystem = require("classes/ParticleSystem")
local ScreenShake = require("classes/ScreenShake")
local LevelManager = require("classes/LevelManager")
local UIManager = require("classes/UIManager")
local Menu = require("classes/Menu")
local BackgroundManager = require("classes/BackgroundManager")

local math_pi = math.pi
local math_cos = math.cos
local math_sin = math.sin
local math_min = math.min
local math_random = math.random
local math_max = math.max
local table_insert, table_remove = table.insert, table.remove

-- Game variables
local showCollisionDebug = false
local screenWidth, screenHeight
local foods, foodSpawnTimer, foodSpawnRate
local sounds, colors, shapeDrawers, polygons
local gameState, score, health, playerSize, foodsEaten

local MAX_PLAYER_SIZE = 80
local EVOLUTION_BASE_SIZE = 60      -- Base size for first evolution
local EVOLUTION_GROWTH_FACTOR = 1.3 -- Each evolution requires 30% more size than the previous
local playerEvolution = 1

-- Game systems
local player, specialEffect, particleSystem, screenShake, levelManager, uiManager, menu, backgroundManager

local function updateScreenSize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

-- Shape drawing functions
local function generatePolygon(sides)
    local verts = {}
    for i = 0, sides - 1 do
        local angle = i * 2 * math_pi / sides - math_pi / 2
        table_insert(verts, math_cos(angle))
        table_insert(verts, math_sin(angle))
    end
    return verts
end

local function initializeShapeDrawers()
    polygons = {}
    polygons.pentagon = generatePolygon(5)
    polygons.hexagon = generatePolygon(6)
    polygons.heptagon = generatePolygon(7)
    polygons.octagon = generatePolygon(8)
    polygons.nonagon = generatePolygon(9)
    polygons.decagon = generatePolygon(10)

    shapeDrawers = {}

    -- Basic shapes
    shapeDrawers.circle = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.circle("fill", x, y, size / 2)
    end

    shapeDrawers.square = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x - size / 2, y - size / 2, size, size)
    end

    shapeDrawers.rectangle = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x - size / 2, y - size / 3, size, size * 2 / 3)
    end

    shapeDrawers.triangle = function(x, y, size, color)
        love.graphics.setColor(color)
        local angle = 2 * math_pi / 3
        local verts = {}
        for i = 0, 2 do
            table_insert(verts, x + (size / 2) * math_cos(i * angle))
            table_insert(verts, y + (size / 2) * math_sin(i * angle))
        end
        love.graphics.polygon("fill", verts)
    end

    -- Polygon shapes
    shapeDrawers.pentagon = function(x, y, size, color)
        love.graphics.setColor(color)
        local verts = {}
        for i = 1, #polygons.pentagon, 2 do
            table_insert(verts, x + polygons.pentagon[i] * size / 2)
            table_insert(verts, y + polygons.pentagon[i + 1] * size / 2)
        end
        love.graphics.polygon("fill", verts)
    end

    shapeDrawers.hexagon = function(x, y, size, color)
        love.graphics.setColor(color)
        local verts = {}
        for i = 1, #polygons.hexagon, 2 do
            table_insert(verts, x + polygons.hexagon[i] * size / 2)
            table_insert(verts, y + polygons.hexagon[i + 1] * size / 2)
        end
        love.graphics.polygon("fill", verts)
    end

    shapeDrawers.heptagon = function(x, y, size, color)
        love.graphics.setColor(color)
        local verts = {}
        for i = 1, #polygons.heptagon, 2 do
            table_insert(verts, x + polygons.heptagon[i] * size / 2)
            table_insert(verts, y + polygons.heptagon[i + 1] * size / 2)
        end
        love.graphics.polygon("fill", verts)
    end

    shapeDrawers.octagon = function(x, y, size, color)
        love.graphics.setColor(color)
        local verts = {}
        for i = 1, #polygons.octagon, 2 do
            table_insert(verts, x + polygons.octagon[i] * size / 2)
            table_insert(verts, y + polygons.octagon[i + 1] * size / 2)
        end
        love.graphics.polygon("fill", verts)
    end

    shapeDrawers.nonagon = function(x, y, size, color)
        love.graphics.setColor(color)
        local verts = {}
        for i = 1, #polygons.nonagon, 2 do
            table_insert(verts, x + polygons.nonagon[i] * size / 2)
            table_insert(verts, y + polygons.nonagon[i + 1] * size / 2)
        end
        love.graphics.polygon("fill", verts)
    end

    shapeDrawers.decagon = function(x, y, size, color)
        love.graphics.setColor(color)
        local verts = {}
        for i = 1, #polygons.decagon, 2 do
            table_insert(verts, x + polygons.decagon[i] * size / 2)
            table_insert(verts, y + polygons.decagon[i + 1] * size / 2)
        end
        love.graphics.polygon("fill", verts)
    end

    -- Additional shapes
    shapeDrawers.oval = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.ellipse("fill", x, y, size / 2, size / 3)
    end

    shapeDrawers.ellipse = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.ellipse("fill", x, y, size / 2, size / 4)
    end

    shapeDrawers.parallelogram = function(x, y, size, color)
        love.graphics.setColor(color)
        local offset = size / 4
        love.graphics.polygon("fill",
            x - size / 2 + offset, y - size / 2,
            x + size / 2 + offset, y - size / 2,
            x + size / 2 - offset, y + size / 2,
            x - size / 2 - offset, y + size / 2
        )
    end

    shapeDrawers.rhombus = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill",
            x, y - size / 2,
            x + size / 2, y,
            x, y + size / 2,
            x - size / 2, y
        )
    end

    shapeDrawers.trapezoid = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill",
            x - size / 2, y - size / 3,
            x + size / 2, y - size / 3,
            x + size / 3, y + size / 3,
            x - size / 3, y + size / 3
        )
    end

    shapeDrawers.kite = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill",
            x, y - size / 2,
            x + size / 2, y,
            x, y + size / 3,
            x - size / 2, y
        )
    end

    -- 3D-like shapes
    shapeDrawers.cube = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x - size / 2, y - size / 2, size, size)
        love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
        love.graphics.polygon("fill",
            x + size / 2, y - size / 2,
            x + size / 2 + size / 4, y - size / 4,
            x + size / 2 + size / 4, y + size / 2 - size / 4,
            x + size / 2, y + size / 2
        )
        love.graphics.setColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)
        love.graphics.polygon("fill",
            x - size / 2, y + size / 2,
            x + size / 2, y + size / 2,
            x + size / 2 + size / 4, y + size / 2 - size / 4,
            x - size / 2 + size / 4, y + size / 2 - size / 4
        )
    end

    shapeDrawers.cylinder = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.ellipse("fill", x, y, size / 2, size / 4)
        love.graphics.rectangle("fill", x - size / 2, y - size / 4, size, size / 2)
        love.graphics.ellipse("fill", x, y, size / 2, size / 4)
    end

    shapeDrawers.cone = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill", x, y - size / 2, x - size / 2, y + size / 2, x + size / 2, y + size / 2)
        love.graphics.ellipse("fill", x, y + size / 2, size / 2, size / 6)
    end

    shapeDrawers.pyramid = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill", x, y - size / 2, x - size / 2, y + size / 2, x + size / 2, y + size / 2)
        love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
        love.graphics.polygon("fill", x - size / 2, y + size / 2, x, y, x, y + size / 2)
    end

    shapeDrawers.tetrahedron = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill", x, y - size / 2, x - size / 2, y + size / 4, x + size / 2, y + size / 4)
        love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
        love.graphics.polygon("fill", x - size / 2, y + size / 4, x, y + size / 2, x + size / 2, y + size / 4)
    end

    shapeDrawers.octahedron = function(x, y, size, color)
        love.graphics.setColor(color)
        love.graphics.polygon("fill", x, y - size / 2, x - size / 2, y, x, y + size / 2)
        love.graphics.polygon("fill", x, y - size / 2, x + size / 2, y, x, y + size / 2)
        love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
        love.graphics.polygon("fill", x - size / 2, y, x, y + size / 2, x + size / 2, y)
    end

    shapeDrawers.dodecahedron = function(x, y, size, color)
        love.graphics.setColor(color)
        shapeDrawers.pentagon(x, y, size, color)
        love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7)
        love.graphics.circle("fill", x, y, size / 4)
    end

    shapeDrawers.icosahedron = function(x, y, size, color)
        love.graphics.setColor(color)
        for i = 0, 5 do
            local angle = i * 2 * math_pi / 6
            local vx = x + (size / 2) * math_cos(angle)
            local vy = y + (size / 2) * math_sin(angle)
            love.graphics.polygon("fill", x, y, vx, vy,
                x + (size / 2) * math_cos(angle + math_pi / 3),
                y + (size / 2) * math_sin(angle + math_pi / 3))
        end
    end
end

local function spawnFood()
    local foodType = math_random() < 0.7 and "healthy" or "unhealthy"
    local side = math_random(4)
    local x, y, vx, vy

    if side == 1 then -- Top
        x = math_random(screenWidth)
        y = -10
        vx = (math_random() - 0.5) * 100
        vy = math_random(50, 150)
    elseif side == 2 then -- Right
        x = screenWidth + 10
        y = math_random(screenHeight)
        vx = -math_random(50, 150)
        vy = (math_random() - 0.5) * 100
    elseif side == 3 then -- Bottom
        x = math_random(screenWidth)
        y = screenHeight + 10
        vx = (math_random() - 0.5) * 100
        vy = -math_random(50, 150)
    else -- Left
        x = -10
        y = math_random(screenHeight)
        vx = math_random(50, 150)
        vy = (math_random() - 0.5) * 100
    end

    -- Ensure food has a minimum size for better collision detection
    local foodSize = math_random(12, 18)
    local food = Food.new(x, y, vx, vy, foodType, foodSize)
    table_insert(foods, food)
end

local function spawnSpecialEffect()
    local x = math_random(50, screenWidth - 50)
    local y = math_random(50, screenHeight - 50)
    specialEffect = SpecialEffect.new(x, y)
end

local function checkCollision(x1, y1, size1, x2, y2, size2)
    -- For player (square) vs food/special effect (circle) collision
    local halfSize1 = size1 / 2

    -- Find the closest point on the player's square to the circle
    local closestX = math_max(x1 - halfSize1, math_min(x2, x1 + halfSize1))
    local closestY = math_max(y1 - halfSize1, math_min(y2, y1 + halfSize1))

    -- Calculate distance between closest point and circle center
    local distanceX = x2 - closestX
    local distanceY = y2 - closestY

    -- Check if distance is less than circle radius
    return (distanceX * distanceX + distanceY * distanceY) < (size2 / 2) * (size2 / 2)
end

local function getEvolutionThreshold(evolutionLevel)
    return EVOLUTION_BASE_SIZE * (EVOLUTION_GROWTH_FACTOR ^ (evolutionLevel - 1))
end

local function updatePlayerEvolution()
    local newEvolution = 1
    local nextThreshold = getEvolutionThreshold(newEvolution + 1)

    -- Find the highest evolution level the player qualifies for
    while playerSize >= nextThreshold do
        newEvolution = newEvolution + 1
        nextThreshold = getEvolutionThreshold(newEvolution + 1)
    end

    -- Check if we evolved to a new level
    if newEvolution > playerEvolution then
        local levelsEvolved = newEvolution - playerEvolution

        -- Reset player size to default when evolving
        playerSize = 30

        -- Create evolution particles - more particles for higher evolution jumps
        particleSystem:createParticles(player.x, player.y, { 1, 1, 0 }, 20 + (levelsEvolved * 10))
        screenShake:trigger(10 + (levelsEvolved * 5), 1.0 + (levelsEvolved * 0.2))

        -- Update evolution level
        playerEvolution = newEvolution
    else
        playerEvolution = newEvolution
    end
end

local function checkFoodCollisions()
    for i = #foods, 1, -1 do
        local food = foods[i]

        if checkCollision(player.x, player.y, playerSize, food.x, food.y, food.size) then
            if food.type == "healthy" then
                -- Check if we're in food contaminated mode
                -- In the healthy food collision section, replace the evolution checking code:
                if food.type == "healthy" then
                    -- Check if we're in food contaminated mode
                    if specialEffect and specialEffect.active and specialEffect.type == "food_contaminated" then
                        health = math_max(0, health - 20)
                        particleSystem:createParticles(food.x, food.y, colors.unhealthy, 8)
                        screenShake:trigger(3, 0.2)
                        love.audio.play(sounds.unhealthy)
                    else
                        if playerSize < MAX_PLAYER_SIZE then
                            playerSize = playerSize + 2
                        else
                            -- At max size, convert growth to score bonus
                            score = score + 5
                        end

                        updatePlayerEvolution()

                        foodsEaten = foodsEaten + 1
                        score = score + 10
                        particleSystem:createParticles(food.x, food.y, colors.healthy, 8)
                        love.audio.play(sounds.healthy)
                    end
                end
            elseif food.type == "unhealthy" then
                -- Check if we're in all you can eat mode
                if specialEffect and specialEffect.active and specialEffect.type == "all_you_can_eat" then
                    playerSize = playerSize + 2
                    foodsEaten = foodsEaten + 1
                    score = score + 10
                    particleSystem:createParticles(food.x, food.y, colors.healthy, 8)
                else
                    health = math_max(0, health - 10)
                    particleSystem:createParticles(food.x, food.y, colors.unhealthy, 8)
                    screenShake:trigger(5, 0.3)
                    love.audio.play(sounds.unhealthy)
                end
            end

            table_remove(foods, i)
        end
    end
end

local function checkSpecialEffectCollision()
    if specialEffect and specialEffect:isCollectable() then
        local effectSize = 25 -- Slightly larger collision area for special effects

        if checkCollision(player.x, player.y, playerSize, specialEffect.x, specialEffect.y, effectSize) then
            local oldX, oldY = specialEffect:collect()
            particleSystem:createParticles(oldX, oldY, colors.special, 15)
            screenShake:trigger(8, 0.5)

            -- Apply immediate effect for weight gain/loss
            if specialEffect.type == "weight_gain" then
                playerSize = playerSize + 10
                particleSystem:createParticles(player.x, player.y, colors.healthy, 12)
            elseif specialEffect.type == "weight_loss" then
                playerSize = math_max(20, playerSize - 8)
                particleSystem:createParticles(player.x, player.y, colors.special, 12)
            end

            updatePlayerEvolution()

            love.audio.play(sounds.special)
        end
    end
end

local function updateFoods(dt)
    local levelData = levelManager:getCurrentLevelData()

    -- Spawn new foods
    foodSpawnTimer = foodSpawnTimer + dt
    if foodSpawnTimer >= foodSpawnRate / levelData.foodDensity then
        spawnFood()
        foodSpawnTimer = 0
    end

    -- Update existing foods
    for i = #foods, 1, -1 do
        local food = foods[i]

        -- Apply speed multiplier for special effects
        local speedMultiplier = levelData.speedMultiplier
        if specialEffect and specialEffect.active then
            if specialEffect.type == "rush_hour" then
                speedMultiplier = speedMultiplier * 2
            elseif specialEffect.type == "traffic_jam" then
                speedMultiplier = speedMultiplier * 0.5
            end
        end

        food:update(dt, speedMultiplier)

        -- Remove foods that go off screen
        if food:isOffScreen(screenWidth, screenHeight) then
            table_remove(foods, i)
        end
    end

    -- Chance to spawn special effect (only if no active or collectable effect exists)
    if (not specialEffect or (not specialEffect.active and not specialEffect:isCollectable())) and math_random() < 0.005 then
        spawnSpecialEffect()
    end
end

local function startGame()
    gameState = "playing"
    levelManager:reset()
    score = 0
    health = 100
    playerSize = 30
    playerEvolution = 1
    foodsEaten = 0
    foods = {}
    foodSpawnTimer = 0

    updatePlayerEvolution()

    -- Reset player position
    player.x = screenWidth / 2
    player.y = screenHeight / 2

    -- Reset special effect
    specialEffect = nil
end

local function nextLevel()
    levelManager:nextLevel()
    health = 100
    foodsEaten = 0
    foods = {}

    -- Slightly reduce player size each level to maintain challenge
    -- But don't let it go below minimum playable size
    playerSize = math.max(20, playerSize - 3)

    -- Reset player position
    player.x = screenWidth / 2
    player.y = screenHeight / 2

    gameState = "playing"
end

local function handleInput()
    if gameState == "menu" then
        startGame()
    elseif gameState == "gameOver" then
        startGame()
    elseif gameState == "levelComplete" then
        nextLevel()
    end
end

function love.load()
    -- Initialize game settings
    love.window.setTitle("FatPoly")

    -- Initialize managers and systems
    uiManager = UIManager.new()
    menu = Menu.new()
    backgroundManager = BackgroundManager.new()
    player = Player.new()
    particleSystem = ParticleSystem.new()
    screenShake = ScreenShake.new()
    levelManager = LevelManager.new()

    updateScreenSize()
    initializeShapeDrawers()

    -- Load sounds
    sounds = {}
    sounds.background = love.audio.newSource("assets/sounds/background.mp3", "stream")
    sounds.gameOver = love.audio.newSource("assets/sounds/game_over.wav", "static")
    sounds.levelComplete = love.audio.newSource("assets/sounds/level_complete.mp3", "static")
    sounds.healthy = love.audio.newSource("assets/sounds/pickup_healthy.wav", "static")
    sounds.unhealthy = love.audio.newSource("assets/sounds/pickup_unhealthy.wav", "static")
    sounds.special = love.audio.newSource("assets/sounds/pickup_special.mp3", "static")

    -- Set background music to loop
    if sounds.background then
        sounds.background:setLooping(true)
        sounds.background:setVolume(0.3)
        love.audio.play(sounds.background)
    end

    -- Colors
    colors = {
        player = { 1, 1, 1 },           -- White
        healthy = { 0, 1, 0 },          -- Green
        unhealthy = { 1, 0, 0 },        -- Red
        special = { 0.5, 0, 0.5 },      -- Purple
        background = { 0.1, 0.1, 0.1 }, -- Dark gray
        text = { 1, 1, 1 },             -- White
        ui = { 0.8, 0.8, 0.8 }          -- Light gray for UI
    }

    -- Initialize game state
    gameState = "menu"
    foods = {}
    foodSpawnTimer = 0
    foodSpawnRate = 0.5

    -- Set initial player position
    player.x = screenWidth / 2
    player.y = screenHeight / 2
end

function love.update(dt)
    updateScreenSize()

    if gameState == "menu" then
        menu:update(dt)
    elseif gameState == "playing" then
        -- Update player
        player:update(dt, screenWidth, screenHeight)

        -- Update foods and special effects
        updateFoods(dt)

        -- Update special effect if it exists
        if specialEffect then
            specialEffect:update(dt)
        end

        -- Update systems
        particleSystem:update(dt)
        screenShake:update(dt)

        -- Check collisions
        checkFoodCollisions()
        checkSpecialEffectCollision()

        -- Check level completion
        if levelManager:isLevelComplete(foodsEaten) then
            gameState = "levelComplete"
            love.audio.play(sounds.levelComplete)
        end

        -- Check game over
        if health <= 0 then
            gameState = "gameOver"
            love.audio.play(sounds.gameOver)
        end
    end
end

function love.draw()
    -- Draw background based on game state
    if gameState == "menu" then
        backgroundManager:drawMenuBackground(screenWidth, screenHeight)
    elseif gameState == "playing" then
        backgroundManager:drawGameBackground(screenWidth, screenHeight)
    elseif gameState == "gameOver" then
        backgroundManager:drawGameOverBackground(screenWidth, screenHeight)
    elseif gameState == "levelComplete" then
        backgroundManager:drawLevelCompleteBackground(screenWidth, screenHeight)
    end

    -- Apply screen shake for gameplay states
    local shakeX, shakeY = 0, 0
    if gameState == "playing" then
        shakeX, shakeY = screenShake:getOffset()
    end

    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)

    -- Draw game elements
    if gameState == "menu" then
        menu:draw(screenWidth, screenHeight)
    elseif gameState == "playing" then
        -- Draw foods
        for _, food in ipairs(foods) do
            food:draw(shapeDrawers, colors)
        end

        -- Draw special effect
        if specialEffect then
            specialEffect:draw(colors)
        end

        -- Draw player
        player:draw(playerSize, playerEvolution)

        -- Draw particles
        particleSystem:draw()

        -- Draw UI
        uiManager:drawGameUI(health, levelManager.currentLevel, playerSize, foodsEaten,
            levelManager.levelTarget, score, specialEffect or {}, colors,
            screenWidth, screenHeight, playerEvolution)

        if showCollisionDebug and gameState == "playing" then
            love.graphics.setColor(1, 1, 0, 0.3) -- Yellow debug circles
            -- Draw player collision area
            love.graphics.circle("line", player.x, player.y, playerSize / 2)

            -- Draw food collision areas
            for _, food in ipairs(foods) do
                love.graphics.circle("line", food.x, food.y, food.size / 2)
            end

            -- Draw special effect collision area
            if specialEffect and specialEffect:isCollectable() then
                love.graphics.circle("line", specialEffect.x, specialEffect.y, 25)
            end
        end
    elseif gameState == "gameOver" then
        uiManager:drawGameOver(score, screenWidth)
    elseif gameState == "levelComplete" then
        uiManager:drawLevelComplete(levelManager.currentLevel, score, screenWidth)
    end

    love.graphics.pop()
end

-- Input handling
function love.touchpressed(id, x, y, dx, dy, pressure)
    handleInput()

    -- If we're in gameplay, set the target position for movement
    if gameState == "playing" then
        player.inputActive = true
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then -- Left mouse button
        handleInput()

        -- If we're in gameplay, set the target position for movement
        if gameState == "playing" then
            player.inputActive = true
        end
    end
end

function love.mousemoved(x, y, dx, dy)
    -- If mouse button is held down and we're in gameplay, update movement
    if love.mouse.isDown(1) and gameState == "playing" then
        player:moveTowards(x, y, love.timer.getDelta(), screenWidth, screenHeight)
        player.inputActive = true
    end
end

-- Handle window resize
function love.resize(w, h)
    updateScreenSize()
    -- Keep player within new bounds
    if player then
        player:constrainToScreen(screenWidth, screenHeight)
    end
end

-- Android back button and ESC key handling
function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" then
            gameState = "menu"
        else
            love.event.quit()
        end
    elseif key == "f1" then -- Debug toggle
        showCollisionDebug = not showCollisionDebug
    end
end
