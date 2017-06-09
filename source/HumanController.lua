local HumanController = oo.class()

function HumanController:init(actor)
    self.actor = actor
end

function HumanController:update()
    if input.baton:pressed('left') then
        self.actor:moveLeft()
    elseif input.baton:pressed('right') then
        self.actor:moveRight()
    elseif input.baton:pressed('jump') then
        self.actor:jump()
    elseif input.baton:pressed('attack') then
        self.actor:attack()
    elseif input.baton:pressed('special') then
        self.actor:special()
    end
end


return HumanController
