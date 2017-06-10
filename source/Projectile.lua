local Projectile = oo.class()

function Projectile:init(damage, x, y, w, h, vx, vy)
    world:add(self, x, y, w, h)
    self.damage = damage
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.vx = vx
    self.vy = vy
    self.deleted = false -- TODO: do properly?
end

function Projectile:update(dt)
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local actualX, actualY, collisions, len = world:move(self, goalX, goalY, self.filter)
    for i=1,len do
        -- handle collisions
        local o = collisions[i].other
        if o.health ~= nil then
            o:takeDamage(self.damage)
        end
    end
    if len > 0 then
        world:remove(self)
        projectileList:remove(self)
        self.deleted = true
    end

    self.x = actualX
    self.y = actualY
end

function Projectile:draw()
    lg.rectangle('line', self.x, self.y, self.w, self.h)
end

-- collision resolution handler
function Projectile:filter()
    return 'touch'
end

return Projectile
