local Camera = require "external.camera"
local sti = require "external.sti"
local bump = require "external.bump"

local game = {}

canW, canH, canSF, canX, canY = 512, 256, 1, 0, 0
canvas, map, world, Enemies = nil

function love.resize()
    local winW, winH = lg.getWidth(), lg.getHeight()
    canSF = math.min(winW/canW, winH/canH)

    local canScaledW = canW * canSF
    local canScaledH = canH * canSF
    canX = math.floor((winW-canScaledW)/2)
    canY = math.floor((winH-canScaledH)/2)
end

function game.load()
    love.resize() -- calculate canvas scaling

    local f = 1 -- camera scaling factor
    game.cam = Camera.new(canW/2, canH/2, f)

    canvas = lg.newCanvas(canW, canH)
    lg.setCanvas(canvas)
    lg.setBlendMode("alpha")

    map = sti("assets/levels/room1.lua", { "bump" })

    world = bump.newWorld()

    map:bump_init(world)

    Enemies = map:convertToCustomLayer("Enemies") -- give sprites

    --[[
    function Enemies:update(dt)
        for _, sprite in pairs(self.sprites) do
            sprite.r = sprite.r + math.rad(90 * dt)
        end
    end

    function Enemies:draw()
        for _, sprite in pairs(self.sprites) do
            local x = math.floor(sprite.x)
            local y = math.floor(sprite.y)
            local r = sprite.r
            love.graphics.draw(sprite.image, x, y, r)
        end
    end
    --]]


end

function game.update(dt)
    map:update(dt)
end

function game.draw()
    lg.setCanvas(canvas)
    lg.clear()

    game.cam:attach()
    lg.setColor(255, 255, 255, 255)
    map:draw(0, 0, 1, 1)

    lg.setColor(255, 0, 0)
    map:bump_draw(world, 0, 0, 1, 1) -- tx, ty, sx, sy

    game.cam:detach()
    lg.setCanvas()
    lg.setColor(255, 255, 255, 255)
    lg.draw(canvas, canX, canY, 0, canSF, canSF)

end

return game
