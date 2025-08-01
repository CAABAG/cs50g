--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

local POWERUP_EXTRA_BALL_SKIN = 9
local POWERUP_KEY_SKIN = 10

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = {params.ball}
    self.level = params.level
    self.powerups = {}
    self.hasLockedBrick = false

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    for k, brick in pairs(self.bricks) do
        if brick.tier == 4 then
            self.hasLockedBrick = true
        end
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for i, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end

    for i, ball in pairs(self.balls) do
        ball:update(dt)

        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- handle powerup acquire
    local powerupsToRemove = {}
    for p, powerup in pairs(self.powerups) do
        if powerup:collides(self.paddle) then
            table.insert(powerupsToRemove, p)
            if powerup.skin == POWERUP_EXTRA_BALL_SKIN then
                local newBall = Ball(math.random(7))
                newBall:reset()
                newBall.dx = math.random(-200, 200)
                newBall.dy = math.random(-50, -60)

                table.insert(self.balls, newBall)
            elseif powerup.skin == POWERUP_KEY_SKIN then
                for k, brick in pairs(self.bricks) do
                    if brick.tier == 4 then
                        brick.unlocked = true
                    end
                end
                self.hasLockedBrick = false
            end
        end
    end

    -- remove marked powerups
    for p, powerup in pairs(powerupsToRemove) do
        table.remove(self.powerups, powerup)
    end

    -- check if we're not on the last locked brick if the level has one
    local bricksCounter = 0
    if self.hasLockedBrick then
        for k, brick in pairs(self.bricks) do
            if brick.inPlay then
                bricksCounter = bricksCounter + 1
            end
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        for i, ball in pairs(self.balls) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                local extraBallPowerupPresent = false
                for p, powerup in pairs(self.powerups) do
                    if powerup.skin == POWERUP_EXTRA_BALL_SKIN then
                        extraBallPowerupPresent = true
                    end
                end

                -- spawn a powerup if conditions or a chance is fulfilled
                if self.hasLockedBrick then
                    if (bricksCounter > 1 and math.random(1, 10) == 1) or bricksCounter == 1 then
                        table.insert(self.powerups, Powerup(brick.x, brick.y, POWERUP_KEY_SKIN, true))
                    end
                elseif not extraBallPowerupPresent and math.random(1, 100) <= 15 then
                    table.insert(self.powerups, Powerup(brick.x, brick.y, POWERUP_EXTRA_BALL_SKIN, true))
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- can't go above size 4
                    if self.paddle.size < 4 then
                        self.paddle.size = math.min(4, self.paddle.size + 1)
                        self.paddle.width = self.paddle.width + 32
                        self.paddle.x = math.max(self.paddle.x - 16, 0)
                    end

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[1],
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    local ballsToRemove = {}
    for i, ball in pairs(self.balls) do
        -- mark balls which are below the screen to be deleted
        if ball.y >= VIRTUAL_HEIGHT then
            table.insert(ballsToRemove, i)
        end
    end

    -- remove marked balls
    for i, ball in pairs(ballsToRemove) do
        table.remove(self.balls, ball)
    end

    if table.size(self.balls) == 0 then
        -- if there are no more balls, revert to serve state and decrease health
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            if self.paddle.size > 1 then
                self.paddle.size = math.max(1, self.paddle.size - 1)
                self.paddle.width = self.paddle.width - 32
                self.paddle.x = math.min(self.paddle.x + 16, VIRTUAL_WIDTH - self.paddle.width)
            end
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for p, powerup in pairs(self.powerups) do
        powerup:render()
    end

    for i, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end