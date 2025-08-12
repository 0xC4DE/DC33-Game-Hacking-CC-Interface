local computers = {22,25,35,50,51,54,55,56,58,59,61,64,65,66,67,68,70,71,72,73}

local function shutdown()
    for _,id in pairs(computers) do
        commands.exec("computercraft shutdown " .. id)
    end
end

local function turnon()
    for _,id in pairs(computers) do
        commands.exec("computercraft turn-on " .. id)
    end
end

local function resetComputers()
    local filesHosts = {}
    local funcs = {}
    for i=1, 10 do
        local f = (function() filesHosts[tostring(i)] = rednet.lookup("files", "puzzle"..i) end)
        table.insert(funcs, f)
    end
    parallel.waitForAll(unpack(funcs))

    for _, receiver in pairs(filesHosts) do
        rednet.send(receiver, "", "reset")
    end
end

peripheral.find("modem", rednet.open)
while true do
    os.pullEvent("redstone")
    resetComputers()
    print("reset computers")
    sleep(5)
    shutdown()
    print("shutdown computers")
    turnon()
    print("turned them back on")
    commands.exec("setblock ~1 ~ ~ minecraft:air")
end