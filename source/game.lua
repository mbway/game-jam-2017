local Camera = require "external.camera"
local sti = require "external.sti"
local bump = require "external.bump"
local bumpDebug = require "external.bump_debug"

local game = {}

canW, canH, canSF, canX, canY = 512, 256, 1, 0, 0
canvas, map, world = nil

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

    for i, o in ipairs(map.layers.Enemies.objects) do
        --o.properties
        if o.type == 'trashcan' then
            print('loaded trashcan')
        else
            assert(false, string.format("unknown entity type: %s", o.type))
        end
    end

    map:removeLayer('Enemies')

end

function game.update(dt)
    map:update(dt)
end

function game.draw()
    lg.setCanvas(canvas)
    lg.clear()

    game.cam:attach()
    --lg.translate(50, 0)
    lg.setColor(255, 255, 255, 255)
    map:draw(0, 0, 1, 1)

    --lg.setColor(255, 0, 0)
    --local x, y = game.cam:pos()
    bumpDebug.draw(world)

    game.cam:detach()

    --map:bump_draw(world, canW/2-x, canH/2-y, 1, 1) -- tx, ty, sx, sy

    lg.setCanvas()
    lg.setColor(255, 255, 255, 255)
    lg.draw(canvas, canX, canY, 0, canSF, canSF)

end

return game
