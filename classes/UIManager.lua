-- FatPoly - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_floor = math.floor

local function getEvolutionName(level)
    local romanNumerals = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }
    if level <= #romanNumerals then
        return romanNumerals[level]
    else
        return tostring(level)
    end
end

local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local instance = setmetatable({}, UIManager)

    instance.smallFont = love.graphics.newFont(20)
    instance.mediumFont = love.graphics.newFont(30)
    instance.largeFont = love.graphics.newFont(40)

    return instance
end

function UIManager:drawGameUI(health, currentLevel, playerSize, foodsEaten, levelTarget, score, specialEffects, colors,
                              screenWidth, screenHeight, playerEvolution)
    -- Health bar
    local barWidth, barHeight = 200, 20
    local barX, barY = 20, 20

    -- Evolution indicator with Roman numerals
    local currentEvolution = getEvolutionName(playerEvolution)

    -- Background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    -- Health fill
    local healthWidth = (health / 100) * barWidth
    local r, g = health > 50 and (1 - (health - 50) / 50) or 1, health > 50 and 1 or (health / 50)
    love.graphics.setColor(r, g, 0)
    love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)

    -- Border
    love.graphics.setColor(colors.ui)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)

    -- Stats
    love.graphics.setColor(colors.text)
    love.graphics.setFont(self.smallFont)
    love.graphics.print("Level: " .. currentLevel, 20, 50)
    love.graphics.print("Size: " .. math_floor(playerSize), 20, 75)
    love.graphics.print("Food: " .. foodsEaten .. "/" .. levelTarget, 20, 100)
    love.graphics.print("Score: " .. score, 20, 125)
    love.graphics.print("Evo: " .. currentEvolution, 20, 150)

    -- Infinite level indicator
    love.graphics.print("∞ Levels!", 20, 175)

    -- Progress bar
    local progressWidth = 200
    local progress = foodsEaten / levelTarget
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", screenWidth - progressWidth - 20, 20, progressWidth, 10)
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.rectangle("fill", screenWidth - progressWidth - 20, 20, progressWidth * progress, 10)

    -- Active effect display
    if specialEffects.active then
        local effectText = "Active: "
        if specialEffects.type == "rush_hour" then
            effectText = effectText .. "RUSH HOUR!"
        elseif specialEffects.type == "traffic_jam" then
            effectText = effectText .. "Traffic Jam"
        elseif specialEffects.type == "all_you_can_eat" then
            effectText = effectText .. "ALL YOU CAN EAT!"
        elseif specialEffects.type == "food_contaminated" then
            effectText = effectText .. "FOOD CONTAMINATED!"
        elseif specialEffects.type == "weight_gain" then
            effectText = effectText .. "WEIGHT GAIN!"
        elseif specialEffects.type == "weight_loss" then
            effectText = effectText .. "WEIGHT LOSS!"
        end

        local timeLeft = math.ceil(specialEffects.duration - specialEffects.timer)

        -- Visual indicator that effect is active
        local pulse = 0.7 + math.sin(love.timer.getTime() * 8) * 0.3
        love.graphics.setColor(colors.special[1], colors.special[2], colors.special[3], pulse)
        love.graphics.printf(effectText, 0, screenHeight - 60, screenWidth, "center")
        love.graphics.printf(timeLeft .. "s", 0, screenHeight - 40, screenWidth, "center")
    end
end

function UIManager:drawGameOver(score, screenWidth)
    love.graphics.setFont(self.largeFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Over", 0, 150, screenWidth, "center")

    love.graphics.setFont(self.mediumFont)
    love.graphics.printf("Score: " .. score, 0, 250, screenWidth, "center")
    love.graphics.printf("Click/Tap to Restart", 0, 350, screenWidth, "center")
end

function UIManager:drawLevelComplete(currentLevel, score, screenWidth)
    love.graphics.setFont(self.largeFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Level " .. currentLevel .. " Complete!", 0, 150, screenWidth, "center")

    love.graphics.setFont(self.mediumFont)
    love.graphics.printf("Score: " .. score, 0, 250, screenWidth, "center")
    love.graphics.printf("Click/Tap for Next Level", 0, 350, screenWidth, "center")
end

return UIManager
