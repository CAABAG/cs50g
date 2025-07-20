--[[
    GD50
    Breakout Remake

    -- Powerup Class --

    Author: Piotr Brzostowski

    Represents a powerup, which can be picked up by the player to experience
    its effects. For the purpose of solving the Problem set 2 the only effect
    is the additional ball per powerup.
]]

Powerup = Class()

-- a constant value by which we're going to move the powerup each frame
local GRAVITY = 30

function Powerup:init(x, y, skin)
    -- initial coordinates to match the place of the brick, which provides the powerup
    self.x = x
    self.y = y

    -- the dimensions of the powerup
    self.width = 16
    self.height = 16

    -- the skin from the powerup quads
    self.skin = skin

    -- a variable to track whether the powerup needs to be updated or rendered
    self.inPlay = true
end

--[[
    Expects an argument with a bounding box, a paddle,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Powerup:update(dt)
    if not self.inPlay then
        return
    end

    -- shift the powerup down by a constant value
    self.y = self.y + (GRAVITY * dt)
end

function Powerup:render()
    if not self.inPlay then
        return
    end

    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual powerup skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],
        self.x, self.y)
end