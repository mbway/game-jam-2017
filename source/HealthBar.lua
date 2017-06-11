local HealthBar = oo.class()

function HealthBar:init(actor, oy)
    self.actor = actor
    self.scale = 6 -- pixels per HP
    self.maxW = self.actor.maxHealth * self.scale
    self.ox = self.actor.w/2 - self.maxW/2
    self.oy = oy
end

function HealthBar:draw()
    local h = self.actor.health
    if h > 0 and h < self.actor.maxHealth then
        local r, g, b, a = lg.getColor()
        local x, y = self.actor.x+self.ox, self.actor.y+self.oy
        local w = self.actor.health*self.scale

        lg.setColor(0, 0, 0, 200)
        lg.rectangle('fill', x-1, y-1, self.maxW+2, 4)
        lg.setColor(200, 0, 0, 255)
        lg.rectangle('fill', x, y, w, 2)

        lg.setColor(r, g, b, a)
    end
end

return HealthBar
