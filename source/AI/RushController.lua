
local RushController = oo.class()

function RushController:init(actor)
    self.actor = actor
    self.target = nil
    self.patrolDirection = 'left'
end

function RushController:findTarget()
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

function RushController:update(dt)
    self:findTarget()
    if self.target then
        self.actor.running = true
        local dx, dy = getVectorTo(self.actor, self.target)

        if math.abs(dx) > 8 then
            if dx > 0 then
                self.actor:moveRight()
            elseif dx < 0 then
                self.actor:moveLeft()
            end
        end
        if self.actor.jumpWhenNear and math.abs(dx) < 32 then
            self.actor:jump()
        end
    else
        self.actor.running = false

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

return RushController
