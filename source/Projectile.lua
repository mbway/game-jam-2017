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
            if o.solid then
                o:takeDamage(self.damage, self)
                hit = true
            else
                -- no hit
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

function Projectile:draw()
    -- TODO: make fancy
    lg.rectangle('fill', self.x, self.y, self.w, self.h)
end

-- collision resolution handler
function Projectile:filter()
    return 'touch'
end

function Projectile:getCenter()
    return self.x+self.w/2, self.y+self.h/2
end



local SlugProjectile = oo.class(Projectile)

function SlugProjectile:init(damage, x, y, vx, vy)
    Projectile.init(self, damage, x, y, 5, 5, vx, vy)
    self.gravity = math.random(100, 300)

    self.anim = Anim.new(assets['slug_projectile'].frames)
end
function SlugProjectile:update(dt)
    Projectile.update(self, dt)
    self.anim:update(dt)
    self.vy = self.vy + self.gravity*dt
end
function SlugProjectile:draw()
    lg.draw(assets.slug_projectile.image, assets.slug_projectile.quads[self.anim.frame], self.x, self.y, 0)
end


return {
    Projectile,
    SlugProjectile
}
