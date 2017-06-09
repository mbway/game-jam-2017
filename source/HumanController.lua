local HumanController = oo.class()

function HumanController:init(ctrl, actor)
    self.actor = actor
end

function HumanController:update(ctrl)
    if input.baton:pressed('left') then
        self.actor:moveLeft()
    elseif input.baton:pressed('right') then
        self.actor:moveRight()
    elseif input.baton:pressed('up') then
        self.actor:jump()
    elseif input.baton:pressed('shoot') then
        self.actor:shoot()
    end
end


return HumanController
