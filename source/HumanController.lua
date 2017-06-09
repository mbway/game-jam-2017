local HumanController = oo.class()

function HumanController:init(ctrl, actor)
    self.actor = actor
end

function HumanController:update(ctrl)
    if input.baton:pressed('shoot') then
        self.actor:shoot()
    end
end


return HumanController
