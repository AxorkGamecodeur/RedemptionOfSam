local dungeon = {}
dungeon.cols = 9
dungeon.rows = 6
dungeon.roomStart = nil
dungeon.map = {}

function createRoom(pRow, pCol)
    local newRoom = {}

    newRoom.row = pRow
    newRoom.col = pCol

    newRoom.isOpen = false

    newRoom.upDoor = false
    newRoom.rightDoor = false
    newRoom.downDoor = false
    newRoom.leftDoor = false

    return newRoom
end

function genDungeon()
    dungeon.map = {}

    local row, col
    for row=1, dungeon.rows do
        dungeon.map[row] = {}
        for col=1, dungeon.cols do
            dungeon.map[row][col] = createRoom(row, col)
        end
    end

    local roomList = {}
    local rooms = 20

    local rowStart, colStart
    rowStart = math.random(1, dungeon.rows)
    colStart = math.random(1, dungeon.cols)
    local roomStart = dungeon.map[rowStart][colStart]
    roomStart.isOpen = true
    table.insert(roomList, roomStart)
    dungeon.roomStart = roomStart

    while #roomList < rooms do
        local roomSelect = math.random(1, #roomList)
        local sRow = roomList[roomSelect].row
        local sCol = roomList[roomSelect].col
        local room = roomList[roomSelect]
        local newRoom = nil

        local direction = math.random(1, 4)
        local bAddRoom = false
        
        if direction == 1 and sRow > 1 then
            newRoom = dungeon.map[sRow-1][sCol]
            if newRoom.isOpen == false then
                room.upDoor = true
                newRoom.downDoor = true
                bAddRoom = true
            end
        elseif direction == 2 and sCol < dungeon.cols then
            newRoom = dungeon.map[sRow][sCol+1]
            if newRoom.isOpen == false then
                room.rightDoor = true
                newRoom.leftDoor = true
                bAddRoom = true
            end
        elseif direction == 3 and sRow < dungeon.rows then
            newRoom = dungeon.map[sRow+1][sCol]
            if newRoom.isOpen == false then
                room.downDoor = true
                newRoom.upDoor = true
                bAddRoom = true
            end
        elseif direction == 4 and sCol > 1 then
            newRoom = dungeon.map[sRow][sCol-1]
            if newRoom.isOpen == false then
                room.leftDoor = true
                newRoom.rightDoor = true
                bAddRoom = true
            end
        end

        if bAddRoom then
            newRoom.isOpen = true
            table.insert(roomList, newRoom)
        end
    end
end

function love.load()
    genDungeon()
end

function love.update(dt)

end

function love.draw()
    local x, y

    x = 5
    y = 5

    local wCase = 34
    local hCase = 13
    local sCase = 5

   
    for row=1, dungeon.rows do
        x = 5
        for col=1, dungeon.cols do
            local room = dungeon.map[row][col]
            if room.isOpen == false then
                love.graphics.setColor(30/255, 30/255, 30/255)
            else
                if dungeon.roomStart == room then
                    love.graphics.setColor(25/255, 1, 25/255)
                else
                    love.graphics.setColor(1, 1, 1)
                end
            end

            love.graphics.rectangle("fill", x, y, wCase, hCase)
            love.graphics.setColor(1, 50/255, 50/255)
            -- if room.upDoor == true then
            --     love.graphics.rectangle("fill", (x + wCase/2)-2, y-2, 4, 6)
            -- end
            -- if room.rightDoor == true then
            --     love.graphics.rectangle("fill", (x + wCase)-2, (y + hCase/2) - 2, 6, 4)
            -- end
            -- if room.downDoor == true then
            --     love.graphics.rectangle("fill", (x + wCase/2)-2, (y + hCase) - 2, 4, 6)
                
            -- end
            -- if room.leftDoor == true then
            --     love.graphics.rectangle("fill", x-2, (y + hCase/2) - 2, 6, 4)
            -- end
            love.graphics.setColor(1, 1, 1)                
            
            x = x + wCase + sCase
        end
        y = y + hCase + sCase
    end

    love.graphics.setColor(1, 1, 1)                

end

function love.keypressed(key)
    if key == "space" or key == " " then
        genDungeon()
    end
end