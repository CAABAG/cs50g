--[[
    GD50
    Legend of Zelda

    Author: Piotr Brzostowski
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

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerPotWalkState:update(dt)
    if love.keyboard.isDown('lctrl') or love.keyboard.isDown('space') then
        local projectile = Projectile(GAME_OBJECT_DEFS['pot'], self.entity.x, self.entity.y, self.entity.direction)
        table.insert(self.dungeon.currentRoom.projectiles, projectile)

        self.entity.pickedPot = nil
        self.entity:changeState('idle')
    end

    PlayerWalkState.updateSprite(self)
    EntityWalkState.update(self, dt)
    PlayerWalkState.checkDoorways(self, dt)

    if self.entity.pickedPot then
        self.entity.pickedPot.x = self.entity.x
        self.entity.pickedPot.y = self.entity.y - self.entity.pickedPot.height / 2
    end
end

function PlayerPotWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    if self.entity.pickedPot then
        love.graphics.draw(gTextures[self.entity.pickedPot.texture], gFrames[self.entity.pickedPot.texture][self.entity.pickedPot.frame], self.entity.pickedPot.x, self.entity.pickedPot.y)
    end
end
