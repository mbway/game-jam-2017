local Projectile = oo.class()

function Projectile:init(damage, x, y, w, h, vx, vy)
    self.damage = damage
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.vx = vx
    self.vy = vy
end

function Projectile:update(dt)
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local halfW, halfH = self.w / 2, self.h / 2
    local collisions, len = world:querySegment(self.x+halfW, self.y+halfH, goalX+halfW, goalY+halfH, self.filter)
    local hit = false
    for i=1,len do
        -- handle collisions
        local o = collisions[i]
        if o.health ~= nil then -- if damagable (has health)
            o:takeDamage(self.damage)
            if o.solid then
                hit = true
            end
        else
            hit = true
        end
    end
    if hit then
        projectileList:remove(self)
    end

    self.x = goalX
    self.y = goalY
end

function Projectile:collide(other)
    
end

function Projectile:draw()
    lg.rectangle('fill', self.x, self.y, self.w, self.h)
end

-- collision resolution handler
function Projectile:filter()
    return 'touch'
end

return Projectile
