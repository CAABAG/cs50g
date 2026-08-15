--[[
    GD50
    Legend of Zelda

    Author: Piotr Brzostowski
]]

PlayerPotLiftState = Class{__includes = BaseState}

function PlayerPotLiftState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.entity.pickedPot = nil

    local direction = self.entity.direction
    local potPointX, potPointY, potWidth, potHeight

    if direction == 'left' then
        potPointX = self.entity.x - (self.entity.width / 2) + (TILE_SIZE / 3)
        potPointY = self.entity.y + (self.entity.height / 1.5)
    elseif direction == 'right' then
        potPointX = self.entity.x + self.entity.width +  (self.entity.width / 2) - (TILE_SIZE / 3)
        potPointY = self.entity.y + (self.entity.height / 1.5)
    elseif direction == 'up' then
        potPointX = self.entity.x + (self.entity.width / 2)
        potPointY = self.entity.y - (self.entity.height / 5)
    else
        potPointX = self.entity.x + (self.entity.width / 2)
        potPointY = self.entity.y + self.entity.height + (self.entity.height / 4)
    end

    potWidth = 1
    potHeight = 1

    for o, obj in pairs(self.dungeon.currentRoom.objects) do
        if obj.type ~= 'pot' then
            goto continue
        end

        if obj:collides({height = potHeight, width = potWidth, x = potPointX, y = potPointY}) then
            self.entity.pickedPot = obj
            table.remove(self.dungeon.currentRoom.objects, o)
            break
        end

        ::continue::
    end

    -- lift-pot-left, lift-pot-up, etc
    self.entity:changeAnimation('lift-pot-' .. direction)
end

function PlayerPotLiftState:update(dt)
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    -- unless the pot was found
    if self.entity.currentAnimation.timesPlayed > 0 then
        self.entity.currentAnimation.timesPlayed = 0
        if self.entity.pickedPot then
            self.entity:changeState('idle-pot')
        else
            self.entity:changeState('idle')
        end
    end

    if self.entity.pickedPot then
        if self.entity.currentAnimation.currentFrame == 2 then
            self.entity.pickedPot.y = self.entity.pickedPot.y - 0.2
        elseif self.entity.currentAnimation.currentFrame == 3 then
            self.entity.pickedPot.x = self.entity.x
            self.entity.pickedPot.y = self.entity.y - self.entity.pickedPot.height / 2
        end
    end
end

function PlayerPotLiftState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    if self.entity.pickedPot then
        love.graphics.draw(gTextures[self.entity.pickedPot.texture], gFrames[self.entity.pickedPot.texture][self.entity.pickedPot.frame], self.entity.pickedPot.x, self.entity.pickedPot.y)
    end
end
