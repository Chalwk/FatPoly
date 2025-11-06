-- FatPoly - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sin = math.sin
local math_random = math.random

local SpecialEffect = {}
SpecialEffect.__index = SpecialEffect

local effectTypes = {
    { "rush_hour",       "traffic_jam" },
    { "all_you_can_eat", "food_contaminated" },
    { "weight_gain",     "weight_loss" }
}

function SpecialEffect.new(x, y)
    local instance = setmetatable({}, SpecialEffect)

    local pair = effectTypes[math_random(#effectTypes)]
    local effectType = pair[math_random(2)]

    instance.active = false
    instance.type = effectType
    instance.duration = 5
    instance.timer = 0
    instance.x = x
    instance.y = y
    instance.collectableTimer = 8
    instance.collectableTime = 8

    return instance
end

function SpecialEffect:update(dt)
    if self.active then
        self.timer = self.timer + dt
        if self.timer >= self.duration then
            self.active = false
            self.type = nil
            self.x = nil
            self.y = nil
        end
    elseif self:isCollectable() then
        self.collectableTimer = self.collectableTimer - dt
        if self.collectableTimer <= 0 then
            self.type = nil
            self.x = nil
            self.y = nil
        end
    end
end

function SpecialEffect:collect()
    self.active = true
    self.timer = 0
    local oldX, oldY = self.x, self.y
    self.x = nil
    self.y = nil
    return oldX, oldY
end

function SpecialEffect:isCollectable()
    return self.type and self.x and self.y and not self.active
end

function SpecialEffect:draw(colors)
    if self:isCollectable() then
        -- Visual indicator of remaining time (pulsing effect gets faster as time runs out)
        local timeLeft = self.collectableTimer / self.collectableTime
        local pulseSpeed = 5 + (1 - timeLeft) * 10 -- Speed up pulse as time runs out

        love.graphics.setColor(colors.special)
        love.graphics.circle("fill", self.x, self.y, 20)

        local pulse = 1 + math_sin(love.timer.getTime() * pulseSpeed) * 0.2
        love.graphics.setColor(1, 1, 1, timeLeft) -- Fade out as time runs out
        love.graphics.circle("line", self.x, self.y, 20 * pulse)

        -- Draw timer text - CENTERED
        love.graphics.setColor(1, 1, 1)
        local timerText = tostring(math.ceil(self.collectableTimer))
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(timerText)
        local textHeight = font:getHeight()
        love.graphics.print(timerText, self.x - textWidth / 2, self.y - textHeight / 2)
    end
end

return SpecialEffect
