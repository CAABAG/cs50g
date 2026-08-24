--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Projectile = Class{}

function Projectile:init(def, x, y, direction)
    self.texture = def.texture
    self.frame = def.frame

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    self.direction = direction

    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height
end

function Projectile:update(dt)

end

function Projectile:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end
