local spriteManager = {}

spriteManager.spritesList = {}

spriteManager.createSprite = function(pImgName, pImgNb, pX, pY)

    sprite = {}
    sprite.x = pX
    sprite.y = pY
    sprite.frame = 1
    sprite.vx = 0
    sprite.vy = 0
    sprite.flip = 1
    sprite.imgs = {}

    local imgNum
    for imgNum = 1,pImgNb do
        sprite.imgs[imgNum] = love.graphics.newImage("images/"..pImgName..imgNum..".png")
    end   
    sprite.l = sprite.imgs[1]:getWidth()
    sprite.h = sprite.imgs[1]:getHeight()

    table.insert(spriteManager.spritesList, sprite)

    sprite.anim = function(dt)
        sprite.frame = sprite.frame + 24*dt
        if sprite.frame >= #sprite.imgs then
            sprite.frame = 1
        end
    end

    sprite.move = function(dt)
        -- Réduction de la vélocité (=friction)
        sprite.vx = sprite.vx * .9
        sprite.vy = sprite.vy * .9
        if math.abs(sprite.vx) < 0.01 then sprite.vx = 0 end
        if math.abs(sprite.vy) < 0.01 then sprite.vy = 0 end

        -- Application de la vélocité
        sprite.x = sprite.x + sprite.vx
        sprite.y = sprite.y + sprite.vy
    end

    return sprite

end

spriteManager.update = function(dt)
    local n
    for n=1,#spriteManager.spritesList do
        local s = spriteManager.spritesList[n]
        s.move(dt)
        s.anim(dt)
    end
end

spriteManager.draw = function()
    local n
    for n=1,#spriteManager.spritesList do
        local s = spriteManager.spritesList[n]
        local frame = s.imgs[math.floor(s.frame)]
        love.graphics.draw(frame, s.x, s.y, 0, s.flip, 1, s.l/2, s.h/2)
    end
end

return spriteManager