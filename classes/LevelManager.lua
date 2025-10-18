-- FatPoly
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local LevelManager = {}
LevelManager.__index = LevelManager

function LevelManager.new()
    local instance = setmetatable({}, LevelManager)

    instance.currentLevel = 1
    instance.levelTarget = 5 -- Start with 5 foods for level 1

    return instance
end

function LevelManager:getCurrentLevelData()
    -- Dynamically calculate level parameters based on current level
    local speedMultiplier = 1.0 + (self.currentLevel - 1) * 0.2
    local foodDensity = 1.0 + (self.currentLevel - 1) * 0.15
    local target = 5 + math.floor((self.currentLevel - 1) * 1.5)

    -- Cap the speed multiplier to prevent impossible gameplay
    speedMultiplier = math.min(speedMultiplier, 5.0)
    foodDensity = math.min(foodDensity, 4.0)

    return {
        speedMultiplier = speedMultiplier,
        foodDensity = foodDensity,
        target = target
    }
end

function LevelManager:nextLevel()
    self.currentLevel = self.currentLevel + 1
    local levelData = self:getCurrentLevelData()
    self.levelTarget = levelData.target
    return self.levelTarget
end

function LevelManager:reset()
    self.currentLevel = 1
    local levelData = self:getCurrentLevelData()
    self.levelTarget = levelData.target
end

function LevelManager:isLevelComplete(foodsEaten)
    return foodsEaten >= self.levelTarget
end

function LevelManager:getLevelProgress(foodsEaten)
    return foodsEaten / self.levelTarget
end

-- New method to get level parameters for display
function LevelManager:getLevelInfo()
    local levelData = self:getCurrentLevelData()
    return {
        level = self.currentLevel,
        speed = levelData.speedMultiplier,
        density = levelData.foodDensity,
        target = levelData.target
    }
end

return LevelManager
