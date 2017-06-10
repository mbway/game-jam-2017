local HumanController = oo.class()

function HumanController:init(actor)
    self.actor = actor
end

function HumanController:update()
    if input.p1:pressed('left') then
        self.actor:moveLeft()
    elseif input.p1:pressed('right') then
        self.actor:moveRight()
    elseif input.p1:pressed('jump') then
        self.actor:jump()
    elseif input.p1:pressed('attack') then
        self.actor:attack()
    elseif input.p1:pressed('special') then
        self.actor:special()
    end
end


return HumanController
