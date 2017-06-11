local ShootController = oo.class()

function ShootController:init(actor)
    self.actor = actor
    self.target = nil
    self.attack = 1
    self.minDistanceFromTarget = 2
    self.cooldown = 1.0
    self.cooldownTimer = self.cooldown
end

function ShootController:findTarget()
    if self.target then return end -- never forget target

    local isPlayer = function(actor) return actor.type == 'player' end
    local t, dx, dy = actorList:findClosest(self.actor, isPlayer)
    local r = findRoom(self.actor)
    local tRoom = findRoom(t)
    if r and tRoom and r.name == tRoom.name then
        self.target = t
    else
        self.target = nil
    end
end

function ShootController:update(dt)
    self:findTarget()
    if self.target then
        self.actor.running = true

        self.cooldownTimer = self.cooldownTimer - dt
        if self.cooldownTimer <= 0 then
            self.cooldownTimer = self.cooldown
            self.actor:attack()
        end

        local dx, dy = getVectorTo(self.actor, self.target)

        if math.abs(dx) > self.minDistanceFromTarget then
            if dx > 0 then
                self.actor:moveRight()
            elseif dx < 0 then
                self.actor:moveLeft()
            end
        end
    else
        -- patrol until a target is found
        local x, y = self.actor.x, self.actor.y
        if self.patrolDirection == 'left' then
            if x <= self.actor.patrolLeft then
                self.patrolDirection = 'right'
            else
                self.actor:moveLeft()
            end
        else
            if x >= self.actor.patrolRight then
                self.patrolDirection = 'left'
            else
                self.actor:moveRight()
            end
        end
    end

end

return ShootController
