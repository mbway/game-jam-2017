local Checkpoint = oo.class()

Checkpoint.current = nil

function Checkpoint:init(x,y,w,h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Checkpoint:update(dt)
    local l,u = self.x, self.y
    local r,d = l+self.w, u+self.h
    local px = player.x+player.w/2
    local py = player.y+player.h/2
    if px > l and px < r and py > u and py < d then
        if Checkpoint.current ~= self then
            if debugMode then
                print("checkpoint reached")
            end
            Checkpoint.current = self
        end
    end
end

return Checkpoint
