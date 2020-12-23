io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end

-- Constantes
TILEWIDTH = 64
TILEHEIGHT = 64

local spriteManager = require("spriteManager")
local bulletManager = require("bulletManager")

-- Globales utiles
local screenWidth
local screenHeight

local gameState = require("gameState")

-- Le donjon
local dungeon = require("dungeon")

local samSprite = {}
local roomBackground = {}

local currentRoom = {}
currentRoom.doors = {}


function testDoor(pX, pY)
    local n

    for n=1, #currentRoom.doors do
        local c = currentRoom.doors[n]

        if pX > c.x and pX < c.x + c.width and pY > c.y and pY < c.y + c.height then
            return c.type
        end
    end

    return ""
end

function createDoor(pType, pX, pY, pWidth, pHeight)
    local newDoor = {}

    newDoor.x = pX
    newDoor.y = pY
    newDoor.width = pWidth
    newDoor.height = pHeight
    newDoor.type = pType

    return newDoor
end

function loadRoom(pRoom)
    bulletManager.reset()

    currentRoom.doors = {}

    if pRoom.upDoor == true then
        local door = createDoor("upDoor", screenWidth/2 - TILEWIDTH, 5, TILEWIDTH*2, TILEHEIGHT*2)
        table.insert(currentRoom.doors, door)
    end
    if pRoom.rightDoor == true then
        local door = createDoor("rightDoor", screenWidth - TILEWIDTH*2 - 5, screenHeight/2 - TILEHEIGHT, TILEWIDTH*2, TILEHEIGHT*2)
        table.insert(currentRoom.doors, door)
    end
    if pRoom.downDoor == true then
        local door = createDoor("downDoor", screenWidth/2 - TILEWIDTH, screenHeight-TILEHEIGHT*2 - 5, TILEWIDTH*2, TILEHEIGHT*2)
        table.insert(currentRoom.doors, door)
    end
    if pRoom.leftDoor == true then
        local door = createDoor("leftDoor", 5, screenHeight/2 - TILEHEIGHT, TILEWIDTH*2, TILEHEIGHT*2)
        table.insert(currentRoom.doors, door)
    end
    currentRoom.room = pRoom

end

function startGame()
    spriteManager.reset()
    samSprite = spriteManager.createSprite("p1_walk", 11, 0, 0)

    samSprite.x = screenWidth/2
    samSprite.y = screenHeight/2
    samSprite.offsetY = samSprite.h/2 - 6

    dungeon.genDungeon()
    loadRoom(dungeon.roomStart)
end

function love.load()
  
    love.window.setTitle( "Redemption of Sam (c) 2015 David Mekersa from Gamecodeur.fr" )
    love.window.setMode(1024, 768, {fullscreen=false, vsync=true}) --, minwidth=1024, minheight=768})

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    roomBackground = love.graphics.newImage("images/salle.png")

    startGame()
  
end

function love.update(dt)
    local oldX = samSprite.x
    local oldY = samSprite.y

    spriteManager.update(dt)
    bulletManager.update(dt)

    if math.abs(samSprite.vx) < 1 and math.abs(samSprite.vy) < 1 then
        samSprite.frame = 1
    end

    if love.keyboard.isDown("d") then
        samSprite.vx = samSprite.vx + 1
        samSprite.flip = 1
    end
    if love.keyboard.isDown("q") then
        samSprite.vx = samSprite.vx - 1
        samSprite.flip = -1
    end
    if love.keyboard.isDown("z") then
        samSprite.vy = samSprite.vy - 1
    end
    if love.keyboard.isDown("s") then
        samSprite.vy = samSprite.vy + 1
    end

    local newRoom = nil
    local doorType = testDoor(samSprite.x, samSprite.y)
    if doorType ~= "" then
        local newX = samSprite.x
        local newY = samSprite.y
        if doorType == "upDoor" then
            newRoom = dungeon.map[currentRoom.room.row-1][currentRoom.room.col]
            newX = samSprite.x
            newY = screenHeight - TILEHEIGHT*2 - samSprite.h/2 - 10
        elseif doorType == "rightDoor" then
            newRoom = dungeon.map[currentRoom.room.row][currentRoom.room.col+1]
            newX = TILEWIDTH*2 + 10
            newY = samSprite.y
        elseif doorType == "downDoor" then
            newRoom = dungeon.map[currentRoom.room.row+1][currentRoom.room.col]
            newX = samSprite.x
            newY = TILEHEIGHT*2 + samSprite.h/2 + 10
        elseif doorType == "leftDoor" then
            newRoom = dungeon.map[currentRoom.room.row][currentRoom.room.col-1]
            newX = screenWidth - TILEWIDTH*2 - 10
            newY = samSprite.y
        end

        if newRoom ~= nil then
            loadRoom(newRoom)
            samSprite.x = newX
            samSprite.y = newY
        end
    end

    if newRoom == nil then
        local collisionCol
        local collisionRow
        local bHorizontal = false
        local bVertical = false

        collisionCol = math.floor(samSprite.x / TILEWIDTH + 1)
        collisionRow = math.floor(oldY / TILEHEIGHT + 1)

        if gameState.wallMap[collisionRow][collisionCol] > 0 then
            bHorizontal = true
        end

        collisionCol = math.floor(oldX / TILEWIDTH + 1)
        collisionRow = math.floor(samSprite.y / TILEHEIGHT + 1)

        if gameState.wallMap[collisionRow][collisionCol] > 0 then
            bVertical = true
        end

        if bHorizontal then
            samSprite.vx = 0
            samSprite.x = oldX
        end

        if bVertical then
            samSprite.vy = 0
            samSprite.y = oldY
        end
    end
end

function love.draw()
    love.graphics.draw(roomBackground, 0, 0)
    local door
    for door = 1, #currentRoom.doors do
        local d = currentRoom.doors[door]
        love.graphics.rectangle("line", d.x, d.y, d.width, d.height)
    end

    dungeon.drawDungeonMap(currentRoom.room)
    spriteManager.draw()
    bulletManager.draw()
    love.graphics.circle("fill", samSprite.x, samSprite.y , 5)
end

function love.keypressed(key)
    if key == "space" or key == " " then
        startGame()
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        local dx = x - samSprite.x
        local dy = y - samSprite.y

        if math.abs(dx) > math.abs(dy) then
            if  dx < 0 then
                bulletManager.createbullet("sam", samSprite.x, samSprite.y - samSprite.h / 2, -10, 0.6)
            else
                bulletManager.createbullet("sam", samSprite.x, samSprite.y - samSprite.h / 2, 10, 0.6)
            end
        else
            if dy < 0 then
                bulletManager.createbullet("sam", samSprite.x, samSprite.y - samSprite.h / 2, 0, -10)
            else
                bulletManager.createbullet("sam", samSprite.x, samSprite.y - samSprite.h / 2, 0, 10)
            end
        end
    end
end