oo = require "oo"
flux = require "flux"
Anim = require "anim"
EntityList = require "entitylist"
signal = require "signal"
assets = require "assets"
require "external.strict"
require "external.utils"

local limitFrameRate = require "limitframerate"
local game = require "game"
local baton = require "baton"

debugMode = false -- global debug flag (toggle: F1). Use as you wish

lf, ls, la, lp, lt, li, lg, lm, lj, lw = nil


function love.load(arg)

    -- allows debugging (specifically breakpoints) in ZeroBrane
    --if arg[#arg] == '-debug' then require('mobdebug').start() end

    -- for printing in zerobrane
    io.stdout:setvbuf("no")

    lf = love.filesystem
    ls = love.sound
    la = love.audio
    lp = love.physics
    lt = love.thread
    li = love.image
    lg = love.graphics
    lm = love.mouse
    lj = love.joystick
    lw = love.window

    assets.load()

    math.randomseed(os.time())

    game.load()
end


function love.update(dt)
    limitFrameRate(60)

    flux.update(dt) -- update tweening system

    game.update(dt)
end


function love.draw()
    game.draw()
end

function love.keypressed(key, scancode, isRepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        local fullscreen, fstype = lw.getFullscreen()
        lw.setFullscreen(not fullscreen)
    end
end

