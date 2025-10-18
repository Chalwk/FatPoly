-- FatPoly
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos

local table_insert = table.insert

local BackgroundManager = {}
BackgroundManager.__index = BackgroundManager

function BackgroundManager.new()
    local instance = setmetatable({}, BackgroundManager)
    return instance
end

function BackgroundManager:drawMenuBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Animated gradient
    for y = 0, screenHeight, 4 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 2 + progress * 4) + 1) * 0.1

        local r = 0.1 + progress * 0.3 + pulse
        local g = 0.3 + progress * 0.4 + pulse
        local b = 0.1 + progress * 0.2 + pulse

        love.graphics.setColor(r, g, b, 0.8)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Floating shapes
    love.graphics.setColor(0.3, 0.6, 0.3, 0.15)
    for i = 1, 8 do
        local x = (screenWidth / 8) * i
        local y = screenHeight / 2 + math_sin(time + i) * 50
        local size = 40 + math_sin(time * 0.5 + i) * 10

        if i % 3 == 0 then
            love.graphics.circle("fill", x, y, size / 2)
        elseif i % 3 == 1 then
            love.graphics.rectangle("fill", x - size / 2, y - size / 2, size, size)
        else
            love.graphics.polygon("fill", x, y - size / 2, x - size / 2, y + size / 2, x + size / 2, y + size / 2)
        end
    end

    -- Grid pattern
    love.graphics.setColor(0.2, 0.4, 0.2, 0.1)
    local gridSize = 50
    for x = 0, screenWidth, gridSize do
        love.graphics.line(x, 0, x, screenHeight)
    end
    for y = 0, screenHeight, gridSize do
        love.graphics.line(0, y, screenWidth, y)
    end
end

function BackgroundManager:drawGameBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Moving gradient
    for y = 0, screenHeight, 3 do
        local progress = y / screenHeight
        local wave = math_sin(progress * 8 + time) * 0.1
        local r = 0.15 + wave
        local g = 0.2 + progress * 0.2 + wave
        local b = 0.15 + wave

        love.graphics.setColor(r, g, b, 0.6)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Background particles
    love.graphics.setColor(0.4, 0.7, 0.4, 0.2)
    for i = 1, 15 do
        local x = (math_sin(time * 0.3 + i) * 0.5 + 0.5) * screenWidth
        local y = (math_cos(time * 0.4 + i * 0.7) * 0.5 + 0.5) * screenHeight
        local size = 2 + math_sin(time + i) * 1
        love.graphics.circle("fill", x, y, size)
    end

    -- Digestive system patterns
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.3, 0.5, 0.3, 0.15)
    for i = 1, 5 do
        local centerX = screenWidth / 2
        local centerY = screenHeight / 2
        local radius = 80 + i * 40 + math_sin(time + i) * 10
        local segments = 20

        local points = {}
        for j = 0, segments do
            local angle = (j / segments) * math_pi * 2
            local wave = math_sin(angle * 3 + time * 2) * 5
            local x = centerX + math_cos(angle) * (radius + wave)
            local y = centerY + math_sin(angle) * (radius + wave)
            table_insert(points, x)
            table_insert(points, y)
        end
        love.graphics.line(points)
    end
end

function BackgroundManager:drawGameOverBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Dark red gradient
    for y = 0, screenHeight, 4 do
        local progress = y / screenHeight
        local r = 0.3 + progress * 0.1
        local g = 0.1 + progress * 0.05
        local b = 0.1 + progress * 0.05
        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Broken food shapes
    love.graphics.setColor(0.6, 0.2, 0.2, 0.25)
    for i = 1, 6 do
        local x = (screenWidth / 7) * i
        local y = screenHeight / 2 + math_sin(time * 0.7 + i) * 30

        if i % 2 == 0 then
            love.graphics.circle("line", x, y, 25)
            love.graphics.line(x - 15, y - 15, x + 15, y + 15)
            love.graphics.line(x + 15, y - 15, x - 15, y + 15)
        else
            love.graphics.rectangle("line", x - 20, y - 20, 40, 40)
            love.graphics.line(x - 20, y, x + 20, y)
            love.graphics.line(x, y - 20, x, y + 20)
        end
    end

    -- Warning effect
    local pulse = (math_sin(time * 3) + 1) * 0.1
    love.graphics.setColor(0.8, 0.1, 0.1, 0.1 + pulse * 0.1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Crossed pattern
    love.graphics.setColor(0.5, 0.1, 0.1, 0.15)
    love.graphics.setLineWidth(3)
    for i = -screenHeight, screenWidth * 2, 40 do
        love.graphics.line(i, 0, i + screenHeight, screenHeight)
    end
    for i = -screenWidth, screenHeight * 2, 40 do
        love.graphics.line(screenWidth, i, 0, i + screenWidth)
    end
    love.graphics.setLineWidth(1)
end

function BackgroundManager:drawLevelCompleteBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Golden gradient
    for y = 0, screenHeight, 3 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 4 + progress * 6) + 1) * 0.05

        local r = 0.3 + progress * 0.2 + pulse
        local g = 0.25 + progress * 0.3 + pulse
        local b = 0.1 + pulse
        love.graphics.setColor(r, g, b, 0.7)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Sparkling particles
    love.graphics.setColor(1, 0.9, 0.3, 0.4)
    for i = 1, 20 do
        local x = (math_sin(time * 0.5 + i * 0.3) * 0.5 + 0.5) * screenWidth
        local y = (math_cos(time * 0.6 + i * 0.4) * 0.5 + 0.5) * screenHeight
        local size = 3 + math_sin(time * 2 + i) * 2

        love.graphics.circle("fill", x, y, size)
        if i % 4 == 0 then
            love.graphics.circle("fill", x + 8, y, size * 0.7)
            love.graphics.circle("fill", x - 8, y, size * 0.7)
            love.graphics.circle("fill", x, y + 8, size * 0.7)
            love.graphics.circle("fill", x, y - 8, size * 0.7)
        end
    end

    -- Celebration arcs
    love.graphics.setColor(0.8, 0.7, 0.2, 0.2)
    for i = 1, 3 do
        local centerY = screenHeight + 50
        local radius = 150 + i * 80
        love.graphics.arc("line", "open", screenWidth / 2, centerY, radius, math_pi, 2 * math_pi)
    end
end

return BackgroundManager
