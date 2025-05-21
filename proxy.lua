local conn = peripheral.find("modem")
peripheral.find("modem", rednet.open)
rednet.host("files", "turtle")

if rednet.isOpen() == false then
    print("Could not open rednet")
    sleep(1)
end

function send_awake()
    repeat
        print("sending handshake")
        rednet.broadcast("Turtle", "handshake") 
        sleep(1)
    until false
end

function receive_confirm()
    repeat
        local id, message = rednet.receive("complete")
    until message == "complete"
end

print("Waiting for handshake")
parallel.waitForAny(send_awake, receive_confirm)

print("Handshake complete")

local function receive_file()
    local id, data = rednet.receive("file_upload")
    local file = fs.open("startup.lua", "w")
    file.write(data)
    file.close()
    print("Starting the received program!")
    os.run({}, "startup.lua")
end

receive_file()