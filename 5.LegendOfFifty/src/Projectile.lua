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

    self.secondsBroken = 0

    self.direction = direction

    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    self.threshold = 4
    self.thresholdX = 0
    self.thresholdY = 0

    if self.direction == 'left' then
        self.thresholdX = self.x - (self.threshold * TILE_SIZE)
        self.thresholdY = self.y
    elseif self.direction == 'right' then
        self.thresholdX = self.x + (self.threshold * TILE_SIZE)
        self.thresholdY = self.y
    elseif self.direction == 'up' then
        self.thresholdX = self.x
        self.thresholdY = self.y - (self.threshold * TILE_SIZE)
    elseif self.direction == 'down' then
        self.thresholdX = self.x
        self.thresholdY = self.y + (self.threshold * TILE_SIZE)
    end
end

function Projectile:update(dt)
    if self.state == 'broken' then
        self.secondsBroken = self.secondsBroken + dt
        return
    end

    if self.direction == 'left' then
        self.x = self.x - POT_FLY_SPEED * dt
        if self.x <= self.thresholdX then
            self.state = 'broken'
            gSounds['hit-enemy']:play()
        end
    elseif self.direction == 'right' then
        self.x = self.x + POT_FLY_SPEED * dt
        if self.x >= self.thresholdX then
            self.state = 'broken'
            gSounds['hit-enemy']:play()
        end
    elseif self.direction == 'up' then
        self.y = self.y - POT_FLY_SPEED * dt
        if self.y <= self.thresholdY then
            self.state = 'broken'
            gSounds['hit-enemy']:play()
        end
    elseif self.direction == 'down' then
        self.y = self.y + POT_FLY_SPEED * dt
        if self.y >= self.thresholdY then
            self.state = 'broken'
            gSounds['hit-enemy']:play()
        end
    end
end

function Projectile:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end
