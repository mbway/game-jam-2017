local baton = require "external.baton"
local input = {}

local controls = {
    left    = {'key:left',           'button:dpleft',  'axis:leftx-'},
    right   = {'key:right',          'button:dpright', 'axis:leftx+'},
    run     = {'key:lshift',         'button:leftshoulder'},
    jump    = {'key:x', 'key:space', 'button:a'},
    crouch  = {'key:down',           'button:dpdown'},
    attack  = {'key:c',              'button:x'},
    special = {'key:c',              'button:b'}
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
    elseif key == "f12" then
        debugMode = not debugMode
    end
end


return input
