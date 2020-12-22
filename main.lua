io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end

local spriteManager = require("spriteManager")

-- Globales utiles
local screenWidth
local screenHeight

-- Constantes
local TILEWIDTH = 64
local TILEHEIGHT = 64

-- Le donjon
local dungeon = require("dungeon")

local samSprite = {}
local roomBackground = {}

function startGame()
    samSprite = spriteManager.createSprite("p1_walk", 11, 0, 0)

    samSprite.x = screenWidth/2
    samSprite.y = screenHeight/2
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
    spriteManager.update(dt)

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
end

function love.draw()
    love.graphics.draw(roomBackground, 0, 0)
    spriteManager.draw()
end

function love.keypressed(key)
    if key == "space" or key == " " then
    startGame()
    end
end