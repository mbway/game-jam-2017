local Camera = require "external.camera"
local sti = require "external.sti"
local bump = require "external.bump"
local bumpDebug = require "external.bump_debug"
local actors = require "actors"
local Door = require "Door"
local EntityList = require "entitylist"
local Checkpoint = require "checkpoint"

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
rooms = nil
actorList = nil
projectileList = nil
doorsList = nil
checkpointList = nil

local collisions

-- scripting/text stuff
local routine = nil
local text = nil
local textRevealed = 0

function game.load()
    love.resize() -- calculate canvas scaling

    canvas = lg.newCanvas(canW, canH)
    lg.setCanvas(canvas)
    lg.setBlendMode("alpha")
    lg.clear()
    
    signal.clear()
    flux.tweens = {} -- lol hax
    
    local f = 1 -- camera scaling factor
    game.cam = Camera.new(canW/2, canH/2, f)


    map = sti("assets/levels/demo_world.lua", { "bump" })
    
    actorList = EntityList.new()
    projectileList = EntityList.new()
    doorsList = EntityList.new()
    checkpointList = EntityList.new()

    world = bump.newWorld()
    rooms = bump.newWorld()

    map:bump_init(world)
    
    game.fadeout = 0
    
    -- add room rectangles
    for i, o in ipairs(map.layers.Rooms.objects) do
        local room = {
            name = o.name,
            x = o.x,
            y = o.y,
            w = o.width,
            h = o.height,
            enemies = {},
            -- random color
            colR = math.random(0, 255),
            colG = math.random(0, 255),
            colB = math.random(0, 255)
        }
        rooms:add(room, o.x, o.y, o.width, o.height)
    end

    -- add doors
    for i, o in ipairs(map.layers.Doors.objects) do
        local isOpen = o.properties.isOpen or false
        local room = o.properties.room
        assert(room)
        local type = o.type
        assert(type)
        local door = Door.new(o.x, o.y, o.width, o.height, isOpen, room, type)
        doorsList:add(door)
        world:add(door, door.x, door.y, door.w, door.h)
    end
    
    
    -- add checkpoints
    for i, o in ipairs(map.layers.Checkpoints.objects) do
        local cp = Checkpoint.new(o.x, o.y, o.width, o.height)
        checkpointList:add(cp)
    end


    -- add actors
    for i, o in ipairs(map.layers.Actors.objects) do
        if o.type == 'player' then
            local x,y = o.x, o.y
            if Checkpoint.current then
               x = Checkpoint.current.x 
               y = Checkpoint.current.y 
            end
            player = actors.Player.new(x, y)
            actorList:add(player)
        else
            -- enemies
            local e = nil
            if o.type == 'trashcan' then
                e = actors.TrashCan.new(o.x, o.y, o.properties)
            elseif o.type == 'stalker' then
                e = actors.Stalker.new(o.x, o.y, o.properties)
            elseif o.type == 'turret' then
                e = actors.Turret.new(o.x, o.y, o.properties)
            else
                assert(false, string.format("unknown entity type: %s", o.type))
            end

            local r = findRoom(e)
            if r then
                e.room = r
                table.insert(r.enemies, e)
            end
            actorList:add(e)
        end
    end

    -- listen to deaths
    signal.register('death', function(actor)
        local r = actor.room
        if not r then return end

        local alldead = true
        for i,e in ipairs(r.enemies) do
            if not e:isDead() then
                alldead = false
            end
        end
        if alldead then
            for d in doorsList:each() do
                if not d.room.isOpen and d.room == r.name then
                    d:open()
                end
            end
        end
    end)
    signal.register('death', function(actor)
        if actor == player then
            flux.to(game, 2.0, {fadeout = 255})
            :oncomplete(function()
                game.load()
            end)
        end
    end)

    map:removeLayer('Actors')
    map:removeLayer('Rooms')
    map:removeLayer('Doors')

    routine = nil
    text = nil
    textRevealed = 0
    
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

function game.runScript(f)
    setfenv(f, game)
    routine = coroutine.create(f)
    coroutine.resume(routine)
end

function game.say(str)
    text = str
    textRevealed = 0
    coroutine.yield()
    text = nil
end

function game.update(dt)

    if text then
        if textRevealed < #text then
            textRevealed = math.min(textRevealed + dt*25, #text)
        else
            if input.p1:pressed("jump") then
                if routine and coroutine.status(routine) ~= "dead" then
                    -- execute the next part of the script
                    coroutine.resume(routine)
                end
            end
        end

    else

        collisions = {}

        map:update(dt)
        for e in actorList:each() do
            e:update(dt)
        end
        for p in projectileList:each() do
            p:update(dt)
        end
        for cp in checkpointList:each() do
            cp:update(dt)
        end
    end
    for d in doorsList:each() do
        d:update(dt)
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
    for d in doorsList:each() do
        d:draw()
    end

    if debugMode then
        lg.setColor(255, 0, 0)
        bumpDebug.draw(world)
        map:bump_draw(world, 0, 0, 1, 1) -- tx, ty, sx, sy
        local items, len = rooms:getItems()
        for i=1,len do
            local r = items[i]
            lg.setColor(r.colR, r.colG, r.colB, 80)
            lg.rectangle('fill', r.x, r.y, r.w, r.h)
        end
    end

    game.cam:detach()

    if text then
        local x,y,w,h = 50, canH-28, canW-100, 20
        lg.setColor(0,0,0)
        lg.rectangle("fill", x,y,w,h)
        lg.setColor(255,255,255)
        lg.setLineStyle("rough")
        lg.rectangle("line", x,y,w,h)
        lg.printf(text:sub(1,math.floor(textRevealed)), x+2, y, w-4)
        --lg.rectangle("fill", x+2, y+2,)
    end
    lg.setColor(0,0,0,game.fadeout)
    lg.rectangle("fill", 0,0,canW,canH)

    lg.setCanvas()
    lg.setColor(255, 255, 255, 255)
    lg.draw(canvas, canX, canY, 0, canSF, canSF)
end

function findRoom(actor)
    local x, y = actor:getCenter()
    local items, len = rooms:queryPoint(x, y)
    if len > 0 then
        return items[1]
    else
        return nil
    end
end

return game
