-- FatPoly - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem.new()
    local instance = setmetatable({}, ParticleSystem)
    instance.particles = {}
    return instance
end

function ParticleSystem:createParticles(x, y, color, count)
    for _ = 1, count do
        table_insert(self.particles, {
            x = x,
            y = y,
            vx = (math_random() - 0.5) * 200,
            vy = (math_random() - 0.5) * 200,
            life = 1,
            maxLife = 1,
            color = color,
            size = math_random(2, 5)
        })
    end
end

function ParticleSystem:update(dt)
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt

        if p.life <= 0 then
            table_remove(self.particles, i)
        end
    end
end

function ParticleSystem:draw()
    for _, p in ipairs(self.particles) do
        local alpha = p.life / p.maxLife
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
end

function ParticleSystem:clear()
    self.particles = {}
end

return ParticleSystem
