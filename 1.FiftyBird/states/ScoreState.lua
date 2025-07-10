--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
    self.golden_medal = love.graphics.newImage('golden_medal.png')
    self.silver_medal = love.graphics.newImage('silver_medal.png')
    self.bronze_medal = love.graphics.newImage('bronze_medal.png')
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    if self.score > 14 then
        love.graphics.draw(self.golden_medal, 370, 80)
        love.graphics.printf('You\'re awarded a golden medal!', 0, 140, VIRTUAL_WIDTH, 'center')
    elseif self.score > 9 then
        love.graphics.draw(self.silver_medal, 370, 80)
        love.graphics.printf('You\'re awarded a silver medal!', 0, 140, VIRTUAL_WIDTH, 'center')
    elseif self.score > 4 then
        love.graphics.draw(self.bronze_medal, 370, 80)
        love.graphics.printf('You\'re awarded a bronze medal!', 0, 140, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 180, VIRTUAL_WIDTH, 'center')
end