-- FatPoly - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_pi = math.pi
local math_random = math.random

local Food = {}
Food.__index = Food

local healthyShapes = { "circle", "triangle", "pentagon", "hexagon", "octagon", "cylinder", "cone", "tetrahedron", "dodecahedron" }
local unhealthyShapes = { "square", "rectangle", "oval", "ellipse", "parallelogram", "rhombus", "trapezoid", "kite", "cube", "pyramid", "octahedron", "icosahedron" }

function Food.new(x, y, vx, vy, foodType, size)
    local instance = setmetatable({}, Food)

    instance.x = x
    instance.y = y
    instance.vx = vx
    instance.vy = vy
    instance.type = foodType
    instance.size = size or 15
    instance.rotation = math_random() * 2 * math_pi
    instance.rotationSpeed = (math_random() - 0.5) * 2

    -- Assign random shape based on food type
    if foodType == "healthy" then
        instance.shape = healthyShapes[math_random(#healthyShapes)]
    else
        instance.shape = unhealthyShapes[math_random(#unhealthyShapes)]
    end

    return instance
end

function Food:update(dt, speedMultiplier)
    self.x = self.x + self.vx * dt * speedMultiplier
    self.y = self.y + self.vy * dt * speedMultiplier
    self.rotation = self.rotation + self.rotationSpeed * dt
end

function Food:isOffScreen(screenWidth, screenHeight)
    return self.x < -20 or self.x > screenWidth + 20 or
           self.y < -20 or self.y > screenHeight + 20
end

function Food:draw(shapeDrawers, colors)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)

    local color = self.type == "healthy" and colors.healthy or colors.unhealthy
    local drawer = shapeDrawers[self.shape] or shapeDrawers.circle
    drawer(0, 0, self.size, color)

    love.graphics.pop()
end

return Food