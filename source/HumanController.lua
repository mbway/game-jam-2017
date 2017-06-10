local HumanController = oo.class()

function HumanController:init(actor)
    self.actor = actor
    self.jumpCounter = 0
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
        self.jumpCounter = 4
    elseif input.p1:released('jump') then
        self.actor:stopJumping()
        -- if the jump button is released, don't continue buffering the input
        self.jumpCounter = 0
    end
    -- input buffering so that you can jump a few frames before hand
    if self.jumpCounter > 0 then
        self.jumpCounter = self.jumpCounter - 1
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
