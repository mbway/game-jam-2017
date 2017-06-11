local Script = oo.class()

function Script:init(x,y,w,h,code)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.code = loadstring(code or "")
    self.activated = false
end

function Script:update(dt)
    if self.activated then
        return
    end
    
    local l,u = self.x, self.y
    local r,d = l+self.w, u+self.h
    local px = player.x+player.w/2
    local py = player.y+player.h/2
    if px > l and px < r and py > u and py < d then
        self.activated = true
        game.runScript(self.code)
    end
end

return Script
