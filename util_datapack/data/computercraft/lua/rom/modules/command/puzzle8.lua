
--[[
This is the command computer interface, somewhat of a generalized file, since puzzle 1 is simple enough to be duplicated/replicated.

The turtle will be duplicated directly by the command, if all goes well and reset works right, it will also destroy the computer.
If the user figures out a way to directly remote control the turtle, awesome lol

]]--

-- This is used for placing the turtle, it need to be unique, otherwise it can cause... issues
local computerId = 1007
local puzzle_label = "puzzle8"
local puzzle_complete = false
print(puzzle_label)

-- Find modem, open rednet
local modem = peripheral.find("modem")
rednet.open(peripheral.getName(peripheral.find("modem")))
peripheral.find("modem", rednet.open)

-- Ensure hosting rednet with hostname relevant to the puzzle
rednet.host("files", puzzle_label)
rednet.host("reset", puzzle_label)


local function receive_file(data)
    print("Sending received program to turtle")
    fs.delete("/disk/startup") 
    local file = fs.open("/disk/startup", "w")
    file.write(data)
    commands.exec(string.format("setblock ~ ~2 ~ computercraft:turtle_advanced[facing=north]{Fuel:100,ComputerId:%i}", computerId))
    commands.exec(string.format("computercraft turn-on %i", computerId))
    return true
end

local function receive_reset_request() 
    commands.exec(string.format("computercraft shutdown %i", computerId))
    print("I'm resetting really hard rn")
    redstone.setOutput("right", true)
    sleep(1)
    redstone.setOutput("right", false)
    return true
end

-- these *must* be completely custom per-puzzle
local function check_puzzle_complete() 
    local sleepTime = 1 
    -- implement custom puzzle completion logic per-puzzle
    while true do
        x, y, z = commands.getBlockPosition()
        chest1 = {x=x, y=y+2, z=z-2} -- green
        chest2 = {x=x, y=y+4, z=z-2} -- red
        chest3 = {x=x+3, y=y+2, z=z-2} -- yellow
        chest4 = {x=x+3, y=y+4, z=z-2} -- purple
        chest5 = {x=x+6, y=y+2, z=z-2} -- cyan
        chest6 = {x=x+6, y=y+4, z=z-2} -- orange
        chests = {chest1, chest2, chest3, chest4, chest5, chest6}
        chestColors = {"green", "red", "yellow", "purple", "cyan", "orange"} -- indexed, I hope

        local loopBroke = false
        if not puzzle_complete then
            for idx, chest in pairs(chests) do
                block = commands.getBlockInfo(chest.x, chest.y, chest.z)
                if block["name"] == "minecraft:chest" then
                    if #block["nbt"]["Items"] >= 1 then
                        for __idx, item in pairs(block["nbt"]["Items"]) do
                            if item.id ~= "minecraft:"..chestColors[idx].."_concrete" then
                                print(item.id)
                                print("minecraft:"..chestColors[idx].."_concrete")
                                print("Puzzle broke on "..chest.x.." "..chest.y.." "..chest.z)
                                loopBroke = true
                                break
                            end
                        end
                    else
                        loopBroke = true
                        break
                    end
                end
            end
            if not loopBroke then
                print("Puzzle Completed")
                puzzle_complete = true
                commands.exec("playsound minecraft:entity.player.levelup player @a")
                commands.exec("title @a subtitle \"Puzzle 4\"")
                commands.exec("title @a title \"Puzzle Complete\"")
                sleepTime=10
            end
        else
            print("Puzzle Complete")
            sleep(sleepTime)
        end
    end
end 

-- Receive any protocol
local function receive_protocol()
    while true do
        local id, data, proto = rednet.receive()
        print("Received protocol "..proto)
        if proto == "files" then
            receive_reset_request()
            receive_file(data)
        elseif proto == "reset" then
            receive_reset_request()
        end
    end
end
local function solved_puzzle()
    local controlPC
    local sleepTime = 1
    while true do 
        if puzzle_complete then
            if not controlPC then
                controlPC = rednet.lookup("puzzleControl", "controlpc")
            else
                rednet.send(controlPC, {hostname=puzzle_label, pass="supersecretpasskey"}, "puzzleControl")
            end
            commands.exec("scoreboard players set @p "..puzzle_label.." 1")
            sleepTime = 10
        end
        sleep(sleepTime)
    end
end

-- Wait for file, reset, or if a success state is reached
print("Waiting to receive protocols...")
parallel.waitForAny(receive_protocol, check_puzzle_complete, solved_puzzle)