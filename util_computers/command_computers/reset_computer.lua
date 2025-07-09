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


os.pullEvent("redstone")
shutdown()
turnon()
print("reset computers")