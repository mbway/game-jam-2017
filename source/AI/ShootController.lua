local ShootController = oo.class()

function ShootController:init(actor)
    self.target = nil
    self.attack = 1
    self.minDistanceFromTarget = 24
    self.cooldown = 1.0
    self.cooldownTimer = self.cooldown
end

function ShootController:findTarget()
    --TODO: Jeremy: scene list and accompanying find
    --self.target = game.findClosest(self.actor.x, self.actor.y, entitytype)
end

function ShootController:update(dt)
    if self.target then
        self.cooldownTimer = self.cooldownTimer - dt
        if self.cooldownTimer <= 0 then
            self.cooldownTimer = self.cooldown
            self.actor:shoot(self.target)
        end

        vx, vy = getVectorTo(self.actor, self.target)

        if vx > self.minDistanceFromTarget then
            self.actor:moveRight()
        elseif vx < -self.minDistanceFromTarget then
            self.actor:moveLeft()
        end

    else
        self:findTarget()
    end
end

return ShootController
