local puzzle_label = "puzzle1"
local puzzle_complete = false

-- Find modem, open rednet
local modem = peripheral.find("modem")
rednet.open(peripheral.getName(peripheral.find("modem")))
peripheral.find("modem", rednet.open)

-- Ensure hosting rednet with hostname relevant to the puzzle
--rednet.host("files", puzzle_label)
rednet.host("reset", puzzle_label)


-- receive file function
local function receive_file(data)
    print("Sending received program to turtle")
    rednet.send("turtle_"..puzzle_label, data)
    return true
end

local function receive_reset_request() 
    print("I'm resetting really hard rn")
    return true
end

-- these *must* be completely custom per-puzzle
local function check_puzzle_complete() 
    -- implement custom puzzle completion logic per-puzzle
    while not puzzle_complete do
        --print("Puzzle isn't complete!")
        sleep(1)
    end
end 

-- Receive any protocol
local function receive_protocol()
    while true do
        local id, data, proto = rednet.receive()
        if proto == "files" then
            receive_file(data)
        elseif proto == "reset" then
            receive_reset_request()
        end
    end
end

-- Wait for file, reset, or if a success state is reached
parallel.waitForAny(receive_protocol, check_puzzle_complete)
