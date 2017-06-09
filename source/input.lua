local baton = require "external.baton"
local input = {}

local controls = {
    left  = {'key:left',  'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'axis:leftx+', 'button:dpright'},
    up    = {'key:up',    'axis:lefty-', 'button:dpup'},
    down  = {'key:down',  'axis:lefty+', 'button:dpdown'},
    shoot = {'key:x',     'button:a'}
}

function input.init()
    input.p1 = baton.newPlayer(controls, lj.getJoysticks()[1])
end

function love.keypressed(key, scancode, isRepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        local fullscreen, fstype = lw.getFullscreen()
        lw.setFullscreen(not fullscreen)
    end
end


return input
