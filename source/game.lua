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
projectileList = nil

local collisions

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
    projectileList = EntityList.new()

    world = bump.newWorld()

    map:bump_init(world)

    for i, o in ipairs(map.layers.Actors.objects) do
        if o.type == 'trashcan' then
            local e = actors.TrashCan.new(o.x, o.y)
            actorList:add(e)
        elseif o.type == 'player' then
            player = actors.Player.new(o.x, o.y)
            actorList:add(player)
        else
            assert(false, string.format("unknown entity type: %s", o.type))
        end
    end

    map:removeLayer('Actors')
    
    -- tracks all the pairs of entities that touched each other
    -- (but if a,b is in the list then b,a is not also in the list)
    -- therefore each pair only occurs once
    -- so we can loop over it to handle collisions
    
end

function game.alreadyCollided(a, b)
    return collisions[a] and collisions[a][b]
        or (collisions[b] and collisions[b][a]) 
end

function game.addCollision(a, b)
    if not collisions[a] then
        collisions[a] = {}
    end
    collisions[a][b] = true
end

function game.update(dt)
    collisions = {}
    
    map:update(dt)
    for e in actorList:each() do
        e:update(dt)
    end
    for p in projectileList:each() do
        p:update(dt)
    end

    game.cam:lookAt(player.x, player.y)
end

function game.draw()
    lg.setCanvas(canvas)
    --lg.setCanvas()
    lg.clear(37, 19, 19, 255)
    lg.setColor(255, 255, 255, 255)

    game.cam:attach()
    --lg.translate(50, 100)
    lg.setColor(255, 255, 255, 255)
    map:draw(0, 0, 1, 1)

    for e in actorList:each() do
        e:draw()
    end
    for p in projectileList:each() do
        p:draw()
    end

    if debugMode then
        lg.setColor(255, 0, 0)
        bumpDebug.draw(world)
        map:bump_draw(world, 0, 0, 1, 1) -- tx, ty, sx, sy
    end

    game.cam:detach()

    lg.setCanvas()
    lg.setColor(255, 255, 255, 255)
    lg.draw(canvas, canX, canY, 0, canSF, canSF)

end

return game
