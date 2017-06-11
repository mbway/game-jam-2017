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
rooms = nil
actorList = nil
projectileList = nil

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

    local f = 1 -- camera scaling factor
    game.cam = Camera.new(canW/2, canH/2, f)


    map = sti("assets/levels/world.lua", { "bump" })

    actorList = EntityList.new()
    projectileList = EntityList.new()

    world = bump.newWorld()
    rooms = bump.newWorld()

    map:bump_init(world)

    -- add actors
    for i, o in ipairs(map.layers.Actors.objects) do
        if o.type == 'trashcan' then
            local e = actors.TrashCan.new(o.x, o.y, o.properties)
            actorList:add(e)
        elseif o.type == 'stalker' then
            local e = actors.Stalker.new(o.x, o.y, o.properties)
            actorList:add(e)
        elseif o.type == 'player' then
            player = actors.Player.new(o.x, o.y)
            actorList:add(player)
        else
            assert(false, string.format("unknown entity type: %s", o.type))
        end
    end

    -- add room rectangles
    for i, o in ipairs(map.layers.Rooms.objects) do
        local room = {
            name = o.name,
            x = o.x,
            y = o.y,
            w = o.width,
            h = o.height,
            -- random color
            colR = math.random(0, 255),
            colG = math.random(0, 255),
            colB = math.random(0, 255)
        }
        rooms:add(room, o.x, o.y, o.width, o.height)
    end

    map:removeLayer('Actors')
    map:removeLayer('Rooms')
    
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
    
    lg.setCanvas()
    lg.setColor(255, 255, 255, 255)
    lg.draw(canvas, canX, canY, 0, canSF, canSF)
end

function findRoom(x, y)
    local items, len = rooms:queryPoint(x, y)
    if len > 0 then
        return items[1]
    else
        return 'none'
    end
end

return game
