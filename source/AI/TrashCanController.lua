local TrashCanController = oo.class()

function TrashCanController:init(actor)
    self.target = nil
end

function TrashCanController:findTarget()
    --TODO: Jeremy: scene list and accompanying find
    --self.target = game.findClosest(self.actor.x, self.actor.y, entitytype)
end

function TrashCanController:update(dt)
    if self.target then
        vx, vy = getVectorTo(self.actor, self.target)

        if vx > 0 then
            self.actor:moveRight()
        elseif vx < 0 then
            self.actor:moveLeft()
        end
    else
        self:findTarget()
    end
end

return TrashCanController
