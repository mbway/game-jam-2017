local TurretController = oo.class()

function TurretController:init(actor, cooldown, initialWait)
    self.actor = actor
    self.target = nil
    self.attack = 1
    self.cooldown = cooldown or 0.2
    self.initialWait = initialWait or 0.0
    self.cooldownTimer = self.initialWait
    self.room = findRoom(self.actor)
    assert(self.room)
end

function TurretController:findTarget()
    local isPlayer = function(actor) return actor.type == 'player' end
    local t, dx, dy = actorList:findClosest(self.actor, isPlayer)
    local tRoom = findRoom(t)
    if tRoom and self.room.name == tRoom.name then
        self.target = t
    else
        self.target = nil
    end
end

function TurretController:update(dt)
    if self.target then
        self.cooldownTimer = self.cooldownTimer - dt
        if self.cooldownTimer <= 0 then
            self.cooldownTimer = self.cooldown + self.cooldownTimer
            self.actor:attack(self.target)
        end
    else
        self:findTarget()
    end
end

return TurretController
