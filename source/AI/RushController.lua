
local RushController = oo.class()

function RushController:init(actor)
    self.actor = actor
    self.target = nil
end

function RushController:findTarget()
    local isPlayer = function(actor) return actor.type == 'player' end
    local t, dx, dy = actorList:findClosest(self.actor, isPlayer)
    if math.abs(dx) > 10 and findRoom(self.actor.x, self.actor.y).name == findRoom(t.x, t.y).name then
        self.target = t
    else
        self.target = nil
    end
end

function RushController:update(dt)
    self:findTarget()
    if self.target then
        local vx, vy = getVectorTo(self.actor, self.target)

        if vx > 0 then
            self.actor:moveRight()
        elseif vx < 0 then
            self.actor:moveLeft()
        end
    end
end

return RushController
