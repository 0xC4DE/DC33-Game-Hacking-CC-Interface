-- Computer Craft DC33 main computer sender and "grader" with screen

local basalt = require("basalt")

-- Get monitor and sizes
local monitor = peripheral.find("monitor") -- can use .getSize()
width, height = monitor.getSize()
width = width - 2
height = height - 2

-- Create the frame
local main = basalt.createFrame():setTerm(monitor)

-- Waiting for connection from secondary computer
peripheral.find("modem", rednet.open)
rednet.host("files", "main")
local id, message
repeat
    print("Waiting for handshake")
    id, message = rednet.receive("handshake")
until message == "Turtle"
rednet.broadcast("complete", "complete")
print("Handshake complete!")

-- File Sending Logic
local function send_file()
    local turtle = rednet.lookup("files", "turtle")
    if turtle == nil then
        print("Unable to locate the receiver!")
        return false
    end

    local file = fs.open("testfile.lua", "r")
    local data = file.readAll()
    file.close()
    rednet.send(turtle, data, "file_upload")
end

-- Button Init
local send_button = basalt.create("Button"):setSize(15, 3):setPosition(width-15, height-2):setText("Send")
main:addChild(send_button)
send_button:setBackground(colors.green)
send_button:onClick(function(element)
    send_file()
    send_button:setText("Sent!")
end)

local reset_button = basalt.create("Button"):setSize(15,3):setPosition(4, height-2):setText("Reset Puzzle")
main:addChild(reset_button)
reset_button:setBackground(colors.red)
reset_button:onClick(function(element)
    shell.run("main")
    reset_button:setText("Reset!")
end)

basalt.run()
