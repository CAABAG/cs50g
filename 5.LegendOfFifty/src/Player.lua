--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:adjustSolidCollision(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2

    local distanceLeft = self.x + self.width - target.x
    local distanceRight = target.x + target.width - self.x
    local distanceTop = selfY + selfHeight - target.y
    local distanceBottom = target.y + target.height - selfY

    local smallestDistance = 0
    local direction = ''

    if distanceLeft > 0 then
        smallestDistance = distanceLeft
        direction = 'left'
    end

    if distanceRight > 0 and smallestDistance > distanceRight then
        smallestDistance = distanceRight
        direction = 'right'
    end

    if distanceTop > 0 and smallestDistance > distanceTop then
        smallestDistance = distanceTop
        direction = 'top'
    end

    if distanceBottom > 0 and smallestDistance > distanceBottom then
        smallestDistance = distanceBottom
        direction = 'bottom'
    end

    if direction == 'left' then
        self.x = target.x - self.width - 1
    elseif direction == 'right' then
        self.x = target.x + target.width + 1
    elseif direction == 'top' then
        self.y = target.y - self.height - 1
    elseif direction == 'bottom' then
        self.y = target.y + target.height - selfHeight + 1
    end
end

function Player:render()
    Entity.render(self)
    
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end
