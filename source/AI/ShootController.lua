local ShootController = oo.class()

function ShootController:init(actor)
    self.target = nil
    self.attack = 1
    self.minDistanceFromTarget = 24
    self.cooldown = 1.0
    self.cooldownTimer = self.cooldown
end

function ShootController:findTarget()
    local isPlayer = function(actor) return actor.type == 'player' end
    local t, dx, dy = actorList:findClosest(self.actor, isPlayer)
    if math.abs(dx) > 32 and findRoom(self.x, self.y).name == findRoom(t.x, t.y).name then
        self.target = t
    else
        self.target = nil
    end
end

function ShootController:update(dt)
    if self.target then
        self.cooldownTimer = self.cooldownTimer - dt
        if self.cooldownTimer <= 0 then
            self.cooldownTimer = self.cooldown
            self.actor:attack(self.target)
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
