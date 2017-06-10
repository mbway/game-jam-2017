local HumanController = oo.class()

function HumanController:init(actor)
    self.actor = actor
end

function HumanController:update()
    self.actor.running = input.p1:down('run')

    if input.p1:down('left') then
        self.actor:moveLeft()
    end
    if input.p1:down('right') then
        self.actor:moveRight()
    end
    if input.p1:pressed('jump') then
        self.actor:jump()
    end
    if input.p1:pressed('attack') then
        self.actor:attack()
    end
    if input.p1:pressed('special') then
        self.actor:special()
    end
end


return HumanController
