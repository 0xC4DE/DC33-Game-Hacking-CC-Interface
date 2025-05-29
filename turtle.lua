--[[
This is the code that goes on a turtle that is "receiving" a transmission of code,
This file should be named startup.lua and should be placed on a turtle that is 
set to receive a solution for a puzzle. 

Luckily, structure blocks replicate scripts! So as long as the turtle is tagged, it can receive puzzle solutions

!! It's notable that the name of the turtle needs to be changed, it needs to match that on the sending computer !!
!! label set puzzlex !!

This label is used to listen/receive relevant commands

]]--

local label = os.getLabel()
if label == nil then
    error("Label is not set!")
end


function find_modem() 
    -- finds a wireless modem
    local conn = peripheral.find("modem", function(name, wrapped) return wrapped.isWireless() end)
    rednet.open(peripheral.getName(conn))
    rednet.host("files", label) -- Protocol is hosted on "files" with name equal to the tag set
    if rednet.isOpen() == false then
        print("Could not open rednet")
    end
end

local function receive_file()
    local id, data = rednet.receive("files")
    local file = fs.open("startup.lua", "w")

    file.write(data)
    file.close()
    print("Starting the received program!")
    os.run({}, "startup.lua")
end

find_modem()
receive_file()