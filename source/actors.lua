local HumanController = require "HumanController"
local Actor = oo.class()

function Actor:init(x, y, w, h)
    world:add(self, x,y,w,h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.vx = 0
    self.vy = 0
    self.ax = 0
    self.ay = 0
    self.dragX = 0
    self.dragY = 0
    self.vxMax = 999
    self.vyMax = 999
    self.controller = nil
end

function Actor:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function Actor:attack()

end
function Actor:special()
    
end
function Actor:moveLeft()

end
function Actor:moveRight()

end
function Actor:jump()

end

function Actor:onFloor()
    local actualX, actualY, collisions, len = world:check(self, self.x, self.y+1, function (self, other)
        return "touch"
        -- return false if you want to ignore the collision, i.e. this thing isn't a floor object
    end)
    return len > 0
end

-- collision resolution handler
function Actor:filter(other)
    return "slide"
    -- "touch", "cross", "slide", "bounce" or nil to ignore
end

function Actor:update(dt)
    if self.controller then
        self.controller:update(dt)
    end
    if self.ax == 0 then
        if self.vx > 0 then self.vx = math.max(0, self.vx - self.dragX * dt)
        elseif self.vx < 0 then self.vx = math.min(0, self.vx + self.dragX * dt)
        end
    else
        self.vx = self.vx + self.ax * dt
        self.vx = clamp(self.vx, -self.vxMax, self.vxMax)
    end
    
    if self.ay == 0 then
        if self.vy > 0 then self.vy = math.max(0, self.vy - self.dragY * dt)
        elseif self.vy < 0 then self.vy = math.min(0, self.vy + self.dragY * dt)
        end
    else
        self.vy = self.vy + self.ay * dt
        self.vy = clamp(self.vy, -self.vyMax, self.vyMax)
    end
    
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local actualX, actualY, collisions, len = world:move(self, goalX, goalY, self.filter)
    self.x = actualX
    self.y = actualY
end

function Actor:draw()

end


local Player = oo.class(Actor)

function Player:init(x, y)
    Actor.init(self, x, y, 10, 10)
    self.ay = 400
    self.dragX = 400
    self.controller = HumanController.new(self)
end

function Player:update(dt)
    Actor.update(self, dt)
    
    if self:onFloor() then
        self.vy = 0
    end
end

function Player:draw()
    lg.setColor(255,255,0)
    lg.rectangle("fill", self.x, self.y, self.w, self.h)
    lg.setColor(255,255,255)
end

function Player:moveLeft()
    self.vx = -50
end
function Player:moveRight()
    self.vx = 50
end
function Player:jump()
    if self.onFloor() then
        self.vy = -300
    end
end

function Player:filter(other)
    -- todo set vely to 0 on colliding downwards
    return "slide"
end

return {
    Actor = Actor,
    Player = Player
}
