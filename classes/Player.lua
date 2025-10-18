-- FatPoly - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sqrt = math.sqrt
local math_max = math.max
local math_min = math.min

local borderColors = {
    { 0.8, 0.8, 0.8 }, -- Evolution 1: Light Gray
    { 0.1, 0.6, 0.9 }, -- Evolution 2: Blue
    { 0.9, 0.7, 0.1 }, -- Evolution 3: Orange-Gold
    { 0.7, 0.1, 0.9 }, -- Evolution 4: Purple
    { 0.1, 0.9, 0.1 }  -- Evolution 5: Green
}

-- Different colors for different evolution stages
local playerColors = {
    { 1,   1,   1 },   -- Evolution 1: White
    { 0.2, 0.8, 1 },   -- Evolution 2: Light Blue
    { 1,   0.8, 0.2 }, -- Evolution 3: Gold
    { 0.8, 0.2, 1 },   -- Evolution 4: Purple
    { 0.2, 1,   0.2 }, -- Evolution 5: Bright Green (for MAX_EVOLUTIONS)
}

local function getEvolutionColor(evolution, colorTable)
    if evolution <= #colorTable then
        return colorTable[evolution]
    else
        -- Cycle through colors for higher evolutions or use a default
        local index = ((evolution - 1) % (#colorTable - 1)) + 2 -- Start from color 2 and cycle
        return colorTable[index]
    end
end

local Player = {}
Player.__index = Player

function Player.new()
    local instance = setmetatable({}, Player)

    instance.x = 0
    instance.y = 0
    instance.size = 30
    instance.speed = 300
    instance.inputActive = false
    instance.evolution = 1 -- Add this line to track evolution internally

    return instance
end

function Player:update(dt, screenWidth, screenHeight)
    -- Keyboard input
    local dx, dy = 0, 0

    if love.keyboard.isDown("w", "up") then
        dy = dy - 1
    end
    if love.keyboard.isDown("s", "down") then
        dy = dy + 1
    end
    if love.keyboard.isDown("a", "left") then
        dx = dx - 1
    end
    if love.keyboard.isDown("d", "right") then
        dx = dx + 1
    end

    -- Normalize diagonal movement
    if dx ~= 0 or dy ~= 0 then
        local len = math_sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
        self.inputActive = true
    end

    -- Touch input (only if no keyboard input)
    if dx == 0 and dy == 0 then
        local touches = love.touch.getTouches()
        if #touches > 0 then
            local touchX, touchY = love.touch.getPosition(touches[1])
            self:moveTowards(touchX, touchY, dt, screenWidth, screenHeight)
            self.inputActive = true
        elseif self.inputActive then
            self.inputActive = false
        end
    end

    self:constrainToScreen(screenWidth, screenHeight)
end

function Player:moveTowards(targetX, targetY, dt, screenWidth, screenHeight)
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math_sqrt(dx * dx + dy * dy)

    if distance > self.size / 4 then
        local speed = self.speed * dt
        self.x = self.x + (dx / distance) * speed
        self.y = self.y + (dy / distance) * speed
    end

    self:constrainToScreen(screenWidth, screenHeight)
end

function Player:constrainToScreen(screenWidth, screenHeight)
    self.x = math_max(self.size / 2, math_min(screenWidth - self.size / 2, self.x))
    self.y = math_max(self.size / 2, math_min(screenHeight - self.size / 2, self.y))
end

function Player:draw(size, evolution)
    self.size = size
    if evolution then -- Only update evolution if parameter is provided
        self.evolution = evolution
    end

    -- Ensure evolution is within bounds
    local currentColor = getEvolutionColor(self.evolution, playerColors)
    local borderColor = getEvolutionColor(self.evolution, borderColors)

    love.graphics.setColor(currentColor)
    love.graphics.rectangle("fill", self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)

    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
end

return Player
