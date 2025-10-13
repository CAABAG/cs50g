GoalPost = Class{}

function GoalPost:init(def)
    self.x = def.x
    self.y = def.y

    self.flagX = self.x + 8

    self.texture = def.texture
    self.post = def.post
    self.flag = def.flag

    if (self.flag == 1) then
        self.frames = {1, 2, 3}
    elseif (self.flag == 2) then
        self.frames = {4, 5, 6}
    elseif (self.flag == 3) then
        self.frames = {7, 8, 9}
    elseif (self.flag == 4) then
        self.frames = {10, 11, 12}
    end

    self.animation = Animation {
        frames = self.frames,
        interval = 0.2
    }

    self.visible = false
end

function GoalPost:collides(target)
    return false
end

function GoalPost:update(dt)
    self.animation:update(dt)
end

function GoalPost:render()
    if not self.visible then
        return
    end

    love.graphics.draw(gTextures[self.texture], gFrames['posts'][self.post], self.x, self.y)
    love.graphics.draw(gTextures[self.texture], gFrames['flags'][self.animation:getCurrentFrame()], self.flagX, self.y)
end