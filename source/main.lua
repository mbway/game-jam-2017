oo = require "oo"
flux = require "flux"
Anim = require "anim"
EntityList = require "entitylist"
signal = require "signal"
assets = require "assets"
input = require "input"
require "external.strict"
require "external.utils"
require "vector"


local limitFrameRate = require "limitframerate"
game = require "game"

debugMode = false -- global debug flag (toggle: F12). Use as you wish

tileDim = 16

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

    input.init()

    math.randomseed(os.time())

    game.load()
    
    --game.runScript(function()
    --    say "hello world!"
    --    say "the quick brown fox jumps over the lazy dog"
    --    say "she sell sea shells on the sea shore..."
    --    say "ok bye now."
    --end)
end


function love.update(dt)
    limitFrameRate(60)

    flux.update(dt) -- update tweening system

    input.p1:update()
    game.update(dt)
end


function love.draw()
    lg.setFont(assets.font)
    game.draw()

    lg.setColor(100, 100, 100)
    lg.setFont(assets.font_debug)
    lg.print(string.format('FPS: %d', love.timer.getFPS()), 20, 20)
end

