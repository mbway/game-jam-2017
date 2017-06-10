local Camera = require "external.camera"
local sti = require "external.sti"
local bump = require "external.bump"
local bumpDebug = require "external.bump_debug"
local actors = require "actors"
local EntityList = require "entitylist"

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

player = nil
actorList = nil

function game.load()
    love.resize() -- calculate canvas scaling

    canvas = lg.newCanvas(canW, canH)
    lg.setCanvas(canvas)
    lg.setBlendMode("alpha")
    lg.clear()

    local f = 1 -- camera scaling factor
    game.cam = Camera.new(canW/2, canH/2, f)


    map = sti("assets/levels/room1.lua", { "bump" })

    actorList = EntityList.new()

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

    player = actors.Player.new(50, 50)
    actorList:add(player)

end

function game.update(dt)
    map:update(dt)
    for e in actorList:each() do
        e:update(dt)
    end
end

function game.draw()
    lg.setCanvas(canvas)
    --lg.setCanvas()
    lg.clear()
    lg.setColor(255, 255, 255, 255)

    game.cam:attach()
    --lg.translate(50, 100)
    lg.setColor(255, 255, 255, 255)
    map:draw(0, 0, 1, 1)

    for e in actorList:each() do
        e:draw()
    end

    --lg.setColor(255, 0, 0)
    --local x, y = game.cam:pos()
    --bumpDebug.draw(world)
    map:bump_draw(world, 0, 0, 1, 1) -- tx, ty, sx, sy

    game.cam:detach()


    lg.setCanvas()
    lg.setColor(255, 255, 255, 255)
    lg.draw(canvas, canX, canY, 0, canSF, canSF)

end

return game
