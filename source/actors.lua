local HumanController = require "HumanController"
local RushController = require "AI.RushController"
local Projectile = require "Projectile"
local Actor = oo.class()
local Anim = require "anim"

function Actor:init(type, x, y, w, h)
    world:add(self, x, y, w, h)
    self.type = type
    self.health = 4
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.vx = 0
    self.vy = 0
    self.ax = 0--TODO: acceleration currently not used
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
    self.vx = -100
end
function Actor:moveRight()
    self.vx = 100
end
function Actor:jump()
    if self:onFloor() then
        self.vy = -100
    end
end
function Actor:stopJumping()
    if self.vy < 0 then
        self.vy = self.vy*0.5
    end
end
function Actor:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:die()
    end
end
function Actor:die()
    --TODO
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
    Actor.init(self, "player", x, y, 10, 28)
    self.ay = 500 -- gravity
    self.dragX = 400
    self.controller = HumanController.new(self)
    self.anim = Anim.new(assets.player_jump_right.frames)
    self.image = assets.player_jump_right.image
    self.quads = assets.player_jump_right.quads
    self.facing = "right"
    self.running = false
    self.weaponDrawnTimer = 0
    self.fireRateCounter = 0
end

function Player:update(dt)
    Actor.update(self, dt)

    if self.vx > 0 then
        self.facing = "right"
    elseif self.vx < -0 then
        self.facing = "left"
    end

    self.fireRateCounter = self.fireRateCounter - dt

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
    if self.fireRateCounter <= 0 then
        self.fireRateCounter = 0.1
        local p = nil
        local damage = 10

        if self.facing == 'left' then
            p = Projectile.new(damage, self.x-10, self.y+9, 5, 2, -250, 0)
        else
            p = Projectile.new(damage, self.x+17, self.y+9, 5, 2, 250, 0)
        end
        projectileList:add(p)
    end
end

function Player:draw()
    if debugMode then
        lg.setColor(0,0,255)
        lg.rectangle("fill", self.x, self.y, self.w, self.h)
        lg.setColor(255,255,255)
    end
    lg.draw(self.image, self.quads[self.anim.frame], self.x-9, self.y-4)
end

function Player:moveLeft()
    self.vx = self.running and -160 or -100
end
function Player:moveRight()
    self.vx = self.running and 160 or 100
end
function Player:jump()
    if self:onFloor() then
        self.vy = -250
    end
end

function Player:filter(other)
    -- todo set vely to 0 on colliding downwards
    return "slide"
end





local TrashCan = oo.class(Actor)

function TrashCan:init(x, y)
    Actor.init(self, "trashcan", x, y, 16, 26)
    self.ay = 500 -- gravity
    self.dragX = 400
    self.controller = RushController.new(self)
    self.anim = Anim.new(assets.bin.frames)
    self.image = assets.bin.image
    self.quads = assets.bin.quads
    self.facing = "right"
end

function TrashCan:update(dt)
    Actor.update(self, dt)

    if self.vx > 0 then
        self.facing = "right"
    elseif self.vx < -0 then
        self.facing = "left"
    end

    if self:onFloor() then
        self.vy = 0
    end

    self.anim:update(dt)
end

function TrashCan:moveLeft()
    self.vx = -50
end
function TrashCan:moveRight()
    self.vx = 50
end

function TrashCan:attack()

end

function TrashCan:draw()
    if debugMode then
        lg.setColor(255,0,0)
        lg.rectangle("fill", self.x, self.y, self.w, self.h)
        lg.setColor(255,255,255)
    end
    if self.facing == 'left' then
        lg.draw(self.image, self.quads[self.anim.frame], self.x-8, self.y-6)
    else
        lg.draw(self.image, self.quads[self.anim.frame], self.x+24, self.y-6, 0, -1, 1)
    end
end

function TrashCan:filter(other)
    -- todo set vely to 0 on colliding downwards
    return "slide"
end




return {
    Actor = Actor,
    Player = Player,
    TrashCan = TrashCan
}
