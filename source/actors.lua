local HumanController = require "HumanController"
local Actor = oo.class()
local Anim = require "anim"

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

function Actor:setAnim(name, restart)
    self.anim:play(assets[name].frames, restart)
    self.image = assets[name].image
    self.quads = assets[name].quads
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
    Actor.init(self, x, y, 10, 27)
    self.ay = 500 -- gravity
    self.dragX = 400
    self.controller = HumanController.new(self)
    self.anim = Anim.new(assets.player_jump_right.frames)
    self.image = assets.player_jump_right.image
    self.quads = assets.player_jump_right.quads
    self.facing = "right"
    self.running = false
    self.weaponDrawnTimer = 0
end

function Player:update(dt)
    Actor.update(self, dt)
    
    if self.vx > 0 then
        self.facing = "right"
    elseif self.vx < -0 then
        self.facing = "left"
    end
    
    local postfix = nil
    if self.weaponDrawnTimer > 0 then
        self.weaponDrawnTimer = self.weaponDrawnTimer - dt
        postfix = "aim_"..self.facing
    else
        postfix = self.facing
    end
    
    if self:onFloor() then
        self.vy = 0
        
        if math.abs(self.vx) > 0.5 then
            if self.running then
                self:setAnim("player_run_"..postfix)
            else
                self:setAnim("player_walk_"..postfix)
            end
        else
            self:setAnim("player_idle_"..postfix)
        end
    else
        self:setAnim("player_jump_"..postfix)
    end
    
    self.anim:update(dt)
end

function Player:attack()
    self.weaponDrawnTimer = 1.0
end

function Player:draw()
    --lg.setColor(255,255,0)
    --lg.rectangle("fill", self.x, self.y, self.w, self.h)
    --lg.setColor(255,255,255)
    lg.draw(self.image, self.quads[self.anim.frame], self.x-9, self.y-3)
end

function Player:moveLeft()
    self.vx = self.running and -160 or -100
end
function Player:moveRight()
    self.vx = self.running and 160 or 100
end
function Player:jump()
    if self:onFloor() then
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
