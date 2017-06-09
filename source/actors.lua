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
    self.vxMax = 999
    self.vyMax = 999
end

function Actor:shoot()
    
end

function Actor:filter()
    return "slide"
    -- "touch", "cross", "slide" or "bounce"
end

function Actor:update(dt)
    self.vx = self.vx + self.ax * dt
    self.vx = clamp(self.vx, -self.vxMax, self.vxMax)
    self.vy = self.vy + self.ay * dt
    self.vy = clamp(self.vy, -self.vyMax, self.vyMax)
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local actualX, actualY, collisions, len = world:move(self, goalX, goalY, self.filter)
    self.x = actualX
    self.y = actualY
end

function Actor:draw()
    
end


local Dummy = oo.class(Actor)

function Dummy:init(x, y)
    Actor.init(self, x, y, 10, 10)
    self.vx = 50
end

function Dummy:update(dt)
    Actor.update(self, dt)
end

function Dummy:draw()
    lg.setColor(255,255,0)
    lg.rectangle("fill", self.x, self.y, self.w, self.h)
    lg.setColor(255,255,255)
end

return {
    Actor = Actor,
    Dummy = Dummy
}
