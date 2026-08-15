--[[
    GD50
    Legend of Zelda
]]

PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.anims = {
        ['left'] = 'idle-pot-left',
        ['right'] = 'idle-pot-right',
        ['up'] = 'idle-pot-up',
        ['down'] = 'idle-pot-down'
    }

    self.entity:changeAnimation(self.anims[self.entity.direction])
end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk-pot')
    end
end

function PlayerPotIdleState:render()
    EntityIdleState.render(self)

    love.graphics.draw(gTextures[self.entity.pickedPot.texture], gFrames[self.entity.pickedPot.texture][self.entity.pickedPot.frame], self.entity.pickedPot.x, self.entity.pickedPot.y)
end
