local bulletManager = {}

local gameState = require("gameState")

bulletManager.bulletsList = {}

bulletManager.reset = function()
    bulletManager.bulletsList = {}
end

bulletManager.createbullet = function(pType, pX, pY, pVx, pVy, pLife)
    if pLife == nil then pLife = 50 end

    local bullet = {}
    bullet.type = pType
    bullet.x = pX
    bullet.y = pY
    bullet.vx = pVx
    bullet.vy = pVy    
    bullet.life = pLife
    bullet.isDeleted = false

    table.insert(bulletManager.bulletsList, bullet)

    bullet.anim = function(dt)
    end

    bullet.move = function(dt)
        -- Application de la vélocité
        bullet.x = bullet.x + bullet.vx
        bullet.y = bullet.y + bullet.vy
        bullet.life = bullet.life - 1
        if bullet.life < 0 then
            bullet.isDeleted = true
        end
    end

    return bullet

end

bulletManager.update = function(dt)
    local n
    for n=#bulletManager.bulletsList, 1, -1 do
        local b = bulletManager.bulletsList[n]

        local collisionCol
        local collisionRow

        collisionCol = math.floor(b.x / TILEWIDTH + 1)
        collisionRow = math.floor(b.y / TILEHEIGHT + 1)

        if gameState.wallMap[collisionRow][collisionCol] > 0 or b.isDeleted then
            table.remove(bulletManager.bulletsList, n)
        end

        b.move(dt)
        b.anim(dt)
    end
end

bulletManager.draw = function()
    local n
    for n=1,#bulletManager.bulletsList do
        local b = bulletManager.bulletsList[n]
        love.graphics.circle("fill", b.x, b.y, 10)
        -- love.graphics.draw(frame, s.x, s.y, 0, s.flip, 1, s.l/2, s.h/2)
    end
end

return bulletManager