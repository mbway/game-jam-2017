local Door = oo.class()

function Door:init(x, y, w, h, isOpen, room, type)
    self.type = type
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.isOpen = isOpen
    self.openAmount = isOpen and 1.0 or 0.0
    self.horizontal = self.w > self.h
    if self.horizontal then
        self.variablePart = isOpen and 0 or self.w
    else
        self.variablePart = isOpen and 0 or self.h
    end
    self.variableScale = self.variablePart/16
    self.room = room
    self.solid = true
end

function Door:open()
    if not self.isOpen then
        if debugMode then
            print('door for room '..self.room..' open')
        end
        self.openAmount = 0
        flux.to(self, 4, {openAmount = 1.0}):oncomplete(function()
            self.isOpen = true
            self.solid = false
        end)
    end
end

function Door:close()
    if self.isOpen then
        self.isOpen = false
        self.solid = true
    end
end

function Door:update(dt)
    if self.horizontal then
        self.variablePart = (self.w-16)*(1-self.openAmount)
        self.variableScale = self.variablePart/16
        world:update(self, self.x, self.y, math.max(1, self.variablePart)+16, self.h)
    else
        self.variablePart = (self.h-16)*(1-self.openAmount)
        self.variableScale = self.variablePart/16
        world:update(self, self.x, self.y, self.w, math.max(1, self.variablePart)+16)
    end
end

function Door:draw()
    if self.horizontal then
        if self.type == 'bars' then
            lg.draw(assets.door_bars, assets.door_bars_top, self.x, self.y+16, math.rad(-90), 1, self.variableScale)
            lg.draw(assets.door_bars, assets.door_bars_bottom, self.x+self.variablePart, self.y+16, math.rad(-90))
        else
            assert(false)
        end
    else
        if self.type == 'bars' then
            lg.draw(assets.door_bars, assets.door_bars_top, self.x, self.y, 0, 1, self.variableScale)
            lg.draw(assets.door_bars, assets.door_bars_bottom, self.x, self.y+self.variablePart)
        else
            assert(false)
        end
    end
end

return Door
