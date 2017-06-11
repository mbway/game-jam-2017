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


local function makeSfx(str, count)
    local t = {}
    for i=1, count do
        t[i] = la.newSource(str)
    end
    return t
end

local sfxIndices = setmetatable({}, {__mode='k'})

function assets.playSfx(t, vol)
    local n = sfxIndices[t]
    if not n or n > #t then n = 1 end
    t[n]:stop()
    t[n]:play()
    t[n]:setVolume(vol)
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

local function makeMusic(path)
    local source = la.newSource(path)
    source:setVolume(0)
    source:setLooping(true)
    source:play() -- all music layers play silently in the background
    return source
end

function assets.load()

    lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

    --assets.tiles = lg.newImage("assets/tiles.png")
    --assets.tileqs = makeQuads(assets.tiles, 32, 32)

    addSheet("assets/player/", "player_crouch_right", 32, 32)
    addSheet("assets/player/", "player_crouch_left", 32, 32)
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

    addSheet("assets/", "bin", 32, 32)
    assets.bin_run = assets.bin
    addSheet("assets/", "bin_death", 32, 32)
    assets["bin_death"].frames.loop = false
    assets["bin_death"].timePerFrame = 1/20

    assets.font = lg.newFont("assets/Little-League.ttf", 5)
    assets.font_debug = lg.newFont(18)
    lg.setFont(assets.font)

    assets.bin_idle = oo.aug({}, assets.bin_death, {frames = {2}})

    addSheet("assets/", "stalker", 32, 32)
    addSheet("assets/", "stalker_run", 32, 32)
    addSheet("assets/", "stalker_death", 32, 32)
    assets["stalker_death"].frames.loop = false
    assets["stalker_death"].timePerFrame = 1/20
    assets.stalker_idle = oo.aug({}, assets.stalker, {frames = {1}})

    assets.footstep = {
        la.newSource("assets/sfx/footstep1.ogg", "static"),
        la.newSource("assets/sfx/footstep2.ogg", "static")
    }
    assets.bin_clang = {
        la.newSource("assets/sfx/bin_clang_1.ogg", "static"),
        la.newSource("assets/sfx/bin_clang_2.ogg", "static"),
        la.newSource("assets/sfx/bin_clang_3.ogg", "static")
    }
    assets.text_blip = makeSfx("assets/sfx/text_blip_alt.ogg", 1)
    assets.player_hit = makeSfx("assets/sfx/player_hit.wav", 1)
    assets.player_hit[1]:setVolume(0.8)
    assets.shoot = makeSfx("assets/sfx/shoot.wav", 1)
    assets.shoot[1]:setVolume(0.8)
    
    assets.music_construction = makeMusic("assets/music/tomato_construction.ogg")
    assets.music_caves = makeMusic("assets/music/tomato_caves.ogg")
    assets.music_jungle = makeMusic("assets/music/tomato_jungle.ogg")
    assets.music_castle = makeMusic("assets/music/tomato_castle.ogg")



    addSheet("assets/", "wall_turret", 16, 16)
    assets["wall_turret"].frames.loop = false
    assets["wall_turret"].timePerFrame = 1/20

    addSheet("assets/", "octo", 16, 16)
    addSheet("assets/", "octo_death", 16, 16)
    assets["octo_death"].frames.loop = false
    assets["octo_death"].timePerFrame = 1/20
    assets.octo_idle = oo.aug({}, assets.octo, {frames = {1}})
    assets.octo_run = assets.octo

    addSheet("assets/", "slug", 32, 32)
    assets.slug_idle = oo.aug({}, assets.slug, {frames = {1}})
    assets.slug_death = oo.aug({}, assets.slug, {frames = {1}})
    assets["slug_death"].frames.loop = false
    addSheet("assets/", "slug_projectile", 32, 32)
    addSheet("assets/", "slug_attack", 32, 32)
    assets["slug_attack"].frames.loop = false
    addSheet("assets/", "slug_projectile", 5, 5)


    assets.door_bars = lg.newImage("assets/door_bars.png")
    assets.door_bars_top = lg.newQuad(0, 0, 16, 16, 16, 32)
    assets.door_bars_bottom = lg.newQuad(0, 16, 16, 16, 16, 32)
end

return assets
