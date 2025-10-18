-- FatPoly - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_random = math.random

local ScreenShake = {}
ScreenShake.__index = ScreenShake

function ScreenShake.new()
    local instance = setmetatable({}, ScreenShake)

    instance.active = false
    instance.intensity = 0
    instance.duration = 0
    instance.timer = 0

    return instance
end

function ScreenShake:trigger(intensity, duration)
    self.active = true
    self.intensity = intensity
    self.duration = duration
    self.timer = 0
end

function ScreenShake:update(dt)
    if self.active then
        self.timer = self.timer + dt
        if self.timer >= self.duration then
            self.active = false
        end
    end
end

function ScreenShake:getOffset()
    if not self.active then return 0, 0 end

    local progress = self.timer / self.duration
    local currentIntensity = self.intensity * (1 - progress)
    return math_random(-currentIntensity, currentIntensity),
        math_random(-currentIntensity, currentIntensity)
end

return ScreenShake
