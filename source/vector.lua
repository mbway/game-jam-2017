

function getVectorTo(actorA, actorB)
    ax, ay = actorA:getCenter()
    bx, by = actorB:getCenter()
    return vecMinus(bx, by, ax, ay)
end

function vecMinus(ax, ay, bx, by)
    return ax-bx, ay-by
end
function vecAdd(ax, ay, bx, by)
    return ax+bx, ay+by
end
function vecMagSq(ax, ay)
    return ax*ax + ay*ay
end
function vecMag(ax, ay)
    return math.sqrt(ax*ax + ay*ay)
end
