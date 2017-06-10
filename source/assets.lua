local assets = {}

local function makeQuads(img, quadw, quadh)
    local w, h = img:getDimensions()
    local t = {}
    for y=0, h-1, quadh do
        for x=0, w-1, quadw do
            table.insert(t, lg.newQuad(x, y, quadw, quadh, w, h))
        end
    end
    return t
end

local function makeMask(img)
    local srcPixels = img:getData()
    local maskPixels = li.newImageData(srcPixels:getDimensions())
    maskPixels:mapPixel(function(x,y,r,g,b,a)
        r,g,b,a = srcPixels:getPixel(x,y)
        return 255, 255, 255, (a>0 and 255 or 0)
    end)
    return lg.newImage(maskPixels)
end

local function makeSfx(str, count)
    local t = {}
    for i=1, count do
        t[i] = la.newSource(str)
    end
    return t
end

local sfxIndices = setmetatable({}, {__mode='k'})

function assets.playSfx(t)
    local n = sfxIndices[t]
    if not n or n > #t then n = 1 end
    t[n]:stop()
    t[n]:play()
    sfxIndices[t] = n + 1
end


local function addSheet(prefix, name, quadw, quadh)
    local t = {}
    t.image = lg.newImage(prefix..name..".png")
    t.quads = makeQuads(t.image, quadw, quadh)
    t.frames = {}
    for i=1, #t.quads do t.frames[i]=i end
    assets[name] = t
end

function assets.load()

    lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

    --assets.tiles = lg.newImage("assets/tiles.png")
    --assets.tileqs = makeQuads(assets.tiles, 32, 32)

    addSheet("assets/player/", "player_jump_right", 32, 32)
    addSheet("assets/player/", "player_jump_left", 32, 32)
    addSheet("assets/player/", "player_jump_aim_right", 32, 32)
    addSheet("assets/player/", "player_jump_aim_left", 32, 32)
    addSheet("assets/player/", "player_jump_run_right", 32, 32)
    addSheet("assets/player/", "player_jump_run_left", 32, 32)
    addSheet("assets/player/", "player_jump_run_aim_right", 32, 32)
    addSheet("assets/player/", "player_jump_run_aim_left", 32, 32)
    addSheet("assets/player/", "player_run_right", 32, 32)
    addSheet("assets/player/", "player_run_left", 32, 32)
    addSheet("assets/player/", "player_run_aim_right", 32, 32)
    addSheet("assets/player/", "player_run_aim_left", 32, 32)
    addSheet("assets/player/", "player_walk_right", 32, 32)
    addSheet("assets/player/", "player_walk_left", 32, 32)
    addSheet("assets/player/", "player_walk_aim_right", 32, 32)
    addSheet("assets/player/", "player_walk_aim_left", 32, 32)
    addSheet("assets/player/", "player_idle_right", 32, 32)
    addSheet("assets/player/", "player_idle_left", 32, 32)
    addSheet("assets/player/", "player_idle_aim_right", 32, 32)
    addSheet("assets/player/", "player_idle_aim_left", 32, 32)
    addSheet("assets/player/", "player_death_right", 32, 32)
    assets["player_death_right"].frames.loop = false
    addSheet("assets/player/", "player_death_left", 32, 32)
    assets["player_death_left"].frames.loop = false
    --assets.player_idle_right = oo.aug({}, assets.player_walk_right, {frames = {1}})
    --addSheet "literal_bin_32"

    addSheet("assets/", "bin", 32, 32)
    addSheet("assets/", "bin_death", 32, 32)
    assets["bin_death"].frames.loop = false
    assets["bin_death"].timePerFrame = 1/20
    
    assets.font = lg.newFont("assets/Little-League.ttf", 5)
    assets.font_debug = lg.newFont(18)
    lg.setFont(assets.font)
    
end

return assets
