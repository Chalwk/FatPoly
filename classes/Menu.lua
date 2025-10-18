-- FatPoly
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sin = math.sin

local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)

    instance.title = {
        text = "FatPoly",
        scale = 1,
        scaleDirection = 1,
        scaleSpeed = 0.5,
        minScale = 0.9,
        maxScale = 1.1,
        rotation = 0,
        rotationSpeed = 0.5,
        colorPhase = 0,
        colorSpeed = 2
    }

    instance.smallFont = love.graphics.newFont(20)
    instance.mediumFont = love.graphics.newFont(30)
    instance.largeFont = love.graphics.newFont(40)

    return instance
end

function Menu:update(dt)
    -- Update title animation
    self.title.scale = self.title.scale + self.title.scaleDirection * self.title.scaleSpeed * dt

    if self.title.scale > self.title.maxScale then
        self.title.scale = self.title.maxScale
        self.title.scaleDirection = -1
    elseif self.title.scale < self.title.minScale then
        self.title.scale = self.title.minScale
        self.title.scaleDirection = 1
    end

    self.title.rotation = self.title.rotation + self.title.rotationSpeed * dt
    self.title.colorPhase = self.title.colorPhase + self.title.colorSpeed * dt
end

function Menu:draw(screenWidth, screenHeight)
    -- Calculate rainbow color effect
    local r = (math_sin(self.title.colorPhase) + 1) / 2
    local g = (math_sin(self.title.colorPhase + 2) + 1) / 2
    local b = (math_sin(self.title.colorPhase + 4) + 1) / 2

    -- Draw animated title
    love.graphics.setColor(r, g, b)
    love.graphics.setFont(self.largeFont)

    love.graphics.push()
    love.graphics.translate(screenWidth / 2, screenHeight / 3)
    love.graphics.rotate(math_sin(self.title.rotation) * 0.1)
    love.graphics.scale(self.title.scale, self.title.scale)
    love.graphics.printf(self.title.text, -screenWidth / 2, -self.largeFont:getHeight() / 2, screenWidth, "center")
    love.graphics.pop()

    -- Draw subtitle with fade effect
    local alpha = (math_sin(self.title.colorPhase * 1.5) + 1) / 2
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(self.mediumFont)
    love.graphics.printf("Click/Tap to Start", 0, screenHeight / 2, screenWidth, "center")

    -- Draw instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.smallFont)
    love.graphics.printf("Eat green, avoid red!\nGrow bigger but be careful!", 0, screenHeight / 2 + 80, screenWidth,
        "center")
    love.graphics.printf("WASD/Arrow Keys or Click/Tap to move", 0, screenHeight - 60, screenWidth, "center")

    -- Draw copyright
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.setFont(self.smallFont)
    love.graphics.printf("© 2025 Jericho Crosby – FatPoly", 10, screenHeight - 25, screenWidth - 20, "right")
end

return Menu
