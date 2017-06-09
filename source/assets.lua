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

function assets.load()

    lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

    --assets.tiles = lg.newImage("assets/tiles.png")
    --assets.tileqs = makeQuads(assets.tiles, 32, 32)

end

return assets
