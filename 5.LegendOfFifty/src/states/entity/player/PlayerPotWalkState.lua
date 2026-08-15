--[[
    GD50
    Legend of Zelda
]]

PlayerPotWalkState = Class{__includes = PlayerWalkState}

function PlayerPotWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.anims = {
        ['left'] = 'walk-pot-left',
        ['right'] = 'walk-pot-right',
        ['up'] = 'walk-pot-up',
        ['down'] = 'walk-pot-down'
    }
    -- print(self.anims['left'])

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerPotWalkState:update(dt)
    PlayerWalkState.updateSprite(self)
    EntityWalkState.update(self, dt)
    PlayerWalkState.checkDoorways(self, dt)

    self.entity.pickedPot.x = self.entity.x
    self.entity.pickedPot.y = self.entity.y - self.entity.pickedPot.height / 2
end

function PlayerPotWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    love.graphics.draw(gTextures[self.entity.pickedPot.texture], gFrames[self.entity.pickedPot.texture][self.entity.pickedPot.frame], self.entity.pickedPot.x, self.entity.pickedPot.y)
end
