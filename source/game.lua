local Camera = require "external.camera"

local game = {}

function game.load()
	game.cam = Camera.new(256, 128, 2)
end

function game.update(dt)
	
end

function game.draw()
	game.cam:attach()
	lg.print("hello world!", 10, 10)
	game.cam:detach()
end

return game