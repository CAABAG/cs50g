--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

paletteColors = {
    [1] = {
        ['r'] = 255,
        ['g'] = 255,
        ['b'] = 255
    }
}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = math.random(100) < 2

    -- particle system for a shiny block
    if self.shiny then
        self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 24)
        self.psystem:setParticleLifetime(2)
        self.psystem:setLinearAcceleration(-30, -30, 30, 30)
        self.psystem:setEmissionArea('normal', 1, 1)

        self.psystem:setColors(
            paletteColors[1].r / 255,
            paletteColors[1].g / 255,
            paletteColors[1].b / 255,
            155 / 255,
            paletteColors[1].r / 255,
            paletteColors[1].g / 255,
            paletteColors[1].b / 255,
            0
        )
    end
end

function Tile:update(dt)
    if not self.shiny then
        return
    end
    if  self.psystem:getCount() == 0 then
        self.psystem:emit(12)
    end
    self.psystem:update(dt)
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- draw particle system
    if self.shiny then
        love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
    end
end