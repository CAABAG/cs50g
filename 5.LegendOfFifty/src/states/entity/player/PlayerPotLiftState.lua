--[[
    GD50
    Legend of Zelda
]]

PlayerPotLiftState = Class{__includes = BaseState}

function PlayerPotLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
    self.player.pickedPot = nil

    local direction = self.player.direction
    local potPointX, potPointY, potWidth, potHeight

    if direction == 'left' then
        potPointX = self.player.x - (self.player.width / 2) + (TILE_SIZE / 3)
        potPointY = self.player.y + (self.player.height / 1.5)
    elseif direction == 'right' then
        potPointX = self.player.x + self.player.width +  (self.player.width / 2) - (TILE_SIZE / 3)
        potPointY = self.player.y + (self.player.height / 1.5)
    elseif direction == 'up' then
        potPointX = self.player.x + (self.player.width / 2)
        potPointY = self.player.y - (self.player.height / 5)
    else
        potPointX = self.player.x + (self.player.width / 2)
        potPointY = self.player.y + self.player.height + (self.player.height / 4)
    end

    potWidth = 1
    potHeight = 1

    for o, obj in pairs(self.dungeon.currentRoom.objects) do
        if obj.type ~= 'pot' then
            goto continue
        end

        if obj:collides({height = potHeight, width = potWidth, x = potPointX, y = potPointY}) then
            self.player.pickedPot = obj
            table.remove(self.dungeon.currentRoom.objects, o)
            break
        end

        ::continue::
    end

    -- lift-pot-left, lift-pot-up, etc
    self.player:changeAnimation('lift-pot-' .. direction)
end

function PlayerPotLiftState:update(dt)
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    -- unless the pot was found
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        if self.player.pickedPot then
            self.player:changeState('idle-pot')
        else
            self.player:changeState('idle')
        end
    end

    if self.player.pickedPot then
        if self.player.currentAnimation.currentFrame == 2 then
            self.player.pickedPot.y = self.player.pickedPot.y - 0.2
        elseif self.player.currentAnimation.currentFrame == 3 then
            self.player.pickedPot.x = self.player.x
            self.player.pickedPot.y = self.player.y - self.player.pickedPot.height / 2
        end
    end
end

function PlayerPotLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

    if self.player.pickedPot then
        love.graphics.draw(gTextures[self.player.pickedPot.texture], gFrames[self.player.pickedPot.texture][self.player.pickedPot.frame], self.player.pickedPot.x, self.player.pickedPot.y)
    end
end
