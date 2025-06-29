--[[
This is the control computer, it will automatically say what puzzles have been solved.

this is done by maintaining an internal table indicating which puzzles have been solved.

Puzzle computers will broadcast the solved status of a puzzle periodically after the puzzle is solved
]]--

local computerPasskeys = {
    puzzle1 = "supersecretpasskey",
    puzzle2 = "supersecretpasskey",
    puzzle3 = "supersecretpasskey",
    puzzle4 = "supersecretpasskey",
    puzzle5 = "supersecretpasskey",
    puzzle6 = "supersecretpasskey",
    puzzle7 = "supersecretpasskey",
    puzzle8 = "supersecretpasskey",
    puzzle9 = "supersecretpasskey",
    puzzle10 = "supersecretpasskey"
}

local completedPuzzles = {}

peripheral.find("modem", rednet.open)
rednet.host("puzzleControl", "controlpc")
rednet.host("puzzleRequest", "controlpc")


local function recieveProtocol() 
    while true do
        print("Waiting for receive")
        local id, data, proto = rednet.receive()
        print("Received protocol "..proto)
        if proto == "puzzleControl" then
            local checkPass = computerPasskeys[data["hostname"]]
            if not checkPass or not data["pass"] then
                print("Invalid message received from "..id)
            end
            if data["pass"] == checkPass then
                completedPuzzles[data["hostname"]] = true
            end
        elseif proto == "puzzleRequest" then
            local puzzleNumbers = {}
            for k, v in pairs(completedPuzzles) do
                print(string.sub(k, 5, #k))
                local puzzleNumber = tonumber(string.sub(k, 7, #k))
                print("this is a puzzle number "..puzzleNumber)
                table.insert(puzzleNumbers, puzzleNumber)
            end
            print("Sending response puzzles " .. textutils.serialize(puzzleNumbers))
            rednet.send(id, puzzleNumbers, "puzzleResponse")
        end
    end
end

parallel.waitForAny(recieveProtocol)
