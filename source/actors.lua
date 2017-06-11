local HumanController = require "HumanController"
local RushController = require "AI.RushController"
local Projectile = require "Projectile"
local HealthBar = require "HealthBar"
local Actor = oo.class()
local Anim = require "anim"

function Actor:init(type, x, y, w, h)
    world:add(self, x, y, w, h)
    self.type = type
    self.maxHealth = math.huge
    self.health = math.huge
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
    self.solid = true
    self.invulnTimer = 0
    self.invulnTime = 0.16
    self.flickerTime = 0.08
    self.room = nil -- set when loading the game
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
    if self.invulnTimer <= 0 then
        self.health = self.health - damage
        if self.health <= 0 and self.solid then
            self:die()
        end
        self.invulnTimer = self.invulnTime
    end
end
function Actor:die()
    self.solid = false
    signal.emit('death', self)
end
function Actor:isDead()
    return self.health <= 0
end

function Actor:onFloor()
    local actualX, actualY, collisions, len = world:check(self, self.x, self.y+1, self.filter)
    return len > 0
end

-- collision resolution handler
function Actor:filter(other)
    local solid = self.solid and other.solid
    if other.type and not solid then
        return nil
    else
        return "slide"
    end
    -- "touch", "cross", "slide", "bounce" or nil to ignore
end

function Actor:collide(other)

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

    self.invulnTimer = self.invulnTimer - dt

    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local actualX, actualY, collisions, len = world:move(self, goalX, goalY, self.filter)

    for i,c in ipairs(collisions) do
        if not game.alreadyCollided(c.item, c.other) then
           game.addCollision(c.item, c.other)
           if c.item.collide then c.item:collide(c.other) end
           if c.other.collide then c.other:collide(c.item) end
        end
    end

    self.x = actualX
    self.y = actualY
    return collisions, len
end

function Actor:draw()
    if debugMode then
        lg.setColor(0,0,255)
        lg.rectangle("fill", self.x, self.y, self.w, self.h)
        lg.setColor(255,255,255)
    end

    if self:isDead() or self.invulnTimer <= 0 or self.invulnTimer % (2*self.flickerTime) > self.flickerTime then
        local ox, oy, sx = self:spriteOffsets()
        lg.draw(self.image, self.quads[self.anim.frame], self.x+ox, self.y+oy, 0, sx, 1)
    end
end
-- based on current direction or other factors, change the offsets for drawing the sprite
-- return offset x, offset y, scale x
function Actor:spriteOffsets()
    return 0, 0, 1
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
    self.fireRateTimer = 0
    self.maxHealth = 10
    self.health = 10
    self.invulnTime = 1
end

function Player:update(dt)
    Actor.update(self, dt)

    if not self:isDead() then
        if self.vx > 0 then
            self.facing = "right"
        elseif self.vx < -0 then
            self.facing = "left"
        end

        self.fireRateTimer = self.fireRateTimer - dt

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
            if self.running then
                self:setAnim("player_jump_run_"..postfix)
            else
                self:setAnim("player_jump_"..postfix)
            end
        end
    end

    self.anim:update(dt)
end

function Player:attack()
    if self:isDead() then return end

    self.weaponDrawnTimer = 1.0
    if self.fireRateTimer <= 0 then
        self.fireRateTimer = 0.1
        local p = nil
        local damage = 1

        if self.facing == 'left' then
            p = Projectile.new(damage, self.x-10, self.y+9, 5, 2, -250, 0)
        else
            p = Projectile.new(damage, self.x+17, self.y+9, 5, 2, 250, 0)
        end
        projectileList:add(p)
    end
end

function Player:spriteOffsets()
    if self.facing == 'left' then
        return -11, -4, 1
    else
        return -9, -4, 1
    end
end

function Player:moveLeft()
    if self:isDead() then return end
    self.vx = self.running and -160 or -100
end
function Player:moveRight()
    if self:isDead() then return end
    self.vx = self.running and 160 or 100
end
function Player:jump()
    if self:isDead() then return end
    if self:onFloor() then
        self.vy = -250
    end
end
function Player:takeDamage(damage)
    if not debugMode then
        Actor.takeDamage(self, damage)
    end
end
function Player:die()
    Actor.die(self)
    if self.facing == 'left' then
        self:setAnim("player_death_left")
    else
        self:setAnim('player_death_right')
    end
end





local RushEnemy = oo.class(Actor)

function RushEnemy:init(x, y, w, h, type, sheetName)
    Actor.init(self, type, x, y, w, h)
    self.sheetName = sheetName
    self.ay = 500 -- gravity
    self.dragX = 400
    self.controller = RushController.new(self)
    self.anim = Anim.new(assets[sheetName].frames)
    self:setAnim(sheetName)
    self.facing = "right"
    self.maxHealth = 5
    self.health = 5
    self.patrolLeft  = x
    self.patrolRight = x
    self.running = false
end

function RushEnemy:update(dt)
    local collisions, len = Actor.update(self, dt)

    if not self:isDead() then
        -- handle collisions
        for i=1,len do
            local o = collisions[i].other
            if o.type == 'player' then
                o:takeDamage(1)
            end
        end

        if math.abs(self.vx) < 1 then
            self:setAnim(self.sheetName..'_idle')
        else
            if self.running then
                self:setAnim(self.sheetName..'_run')
            else
                self:setAnim(self.sheetName)
            end
        end
    end

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

function RushEnemy:moveLeft()
    if not self:isDead() then
        self.vx = -50
    end
end
function RushEnemy:moveRight()
    if not self:isDead() then
        self.vx = 50
    end
end
function RushEnemy:die()
    Actor.die(self)
    self:setAnim(self.sheetName.."_death")
end




local TrashCan = oo.class(RushEnemy)

function TrashCan:init(x, y, properties)
    RushEnemy.init(self, x, y, 16, 22, "trashcan", "bin")
    self.maxHealth = 5
    self.health = 5
    self.patrolLeft  = x - (properties.patrolLeft  or 0) * tileDim
    self.patrolRight = x + (properties.patrolRight or 0) * tileDim
    self.healthBar = HealthBar.new(self, -5)
end
function TrashCan:spriteOffsets()
    if self.facing == 'left' then
        return -8, -10, 1
    else
        return 24, -10, -1
    end
end

function TrashCan:draw()
    Actor.draw(self)
    self.healthBar:draw()
end


local Stalker = oo.class(RushEnemy)

function Stalker:init(x, y, properties)
    RushEnemy.init(self, x, y, 12, 29, "stalker", "stalker")
    self.maxHealth = 5
    self.health = 5
    self.patrolLeft  = x - (properties.patrolLeft  or 0) * tileDim
    self.patrolRight = x + (properties.patrolRight or 0) * tileDim
    self.healthBar = HealthBar.new(self, -5)
    self.running = false
end

function Stalker:moveLeft()
    if not self:isDead() then
        if self.running then
            self.vx = -90
        else
            self.vx = -60
        end
    end
end
function Stalker:moveRight()
    if not self:isDead() then
        if self.running then
            self.vx = 90
        else
            self.vx = 60
        end
    end
end
function Stalker:spriteOffsets()
    if self.facing == 'left' then
        return 20, -3, -1
    else
        return -8, -3, 1
    end
end
function Stalker:draw()
    Actor.draw(self)
    self.healthBar:draw()
end


return {
    Actor = Actor,
    Player = Player,
    TrashCan = TrashCan,
    Stalker = Stalker
}
