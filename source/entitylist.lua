-- List designed for storing game objects
-- Every table that is added will be assigned an 'id' field to indicate its position in the list
-- Removing entities from the list will not change the position of others in the list (so IDs remain valid)

local EntityList = oo.class()

function EntityList:init()
    self.endPos = 1
end

function EntityList:add(e)
    local insertPos = 1

    while self[insertPos] do
        insertPos = insertPos + 1
    end

    self[insertPos] = e
    e.id = insertPos

    if insertPos >= self.endPos then
        self.endPos = insertPos + 1
    end
end

function EntityList:remove(e)
    self[e.id] = nil
    e.id = nil
    while not self[self.endPos-1] and self.endPos > 1 do
        self.endPos = self.endPos - 1
    end
end


-- returns an iterator to loop over the list while skipping empty elements

function EntityList:each()
    local i = 0
    return function ()
        i = i + 1
        while not self[i] do
            if i >= self.endPos then
                return
            else
                i = i + 1
            end
        end
        return self[i]
    end
end

-- find the closest entity to 'from' which satisfies the predicate function
-- eg predicate = function(actor) return actor.type == 'Player' end
function EntityList:findClosest(from, predicate)
    local closest = nil
    local closestSqDist = math.huge
    local closestdx, closestdy = math.huge
    for e in self:each() do
        if predicate(e) then
            local dx, dy = getVectorTo(from, e)
            local d = vecMagSq(dx, dy)
            if d < closestSqDist then
                closest = e
                closestSqDist = d
                closestdx, closestdy = dx, dy
            end
        end
    end
    return closest, closestdx, closestdy
end

return EntityList
