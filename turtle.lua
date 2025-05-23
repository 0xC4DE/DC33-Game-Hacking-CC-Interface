
function find_modem() 
    local conn = peripheral.find("modem")
    peripheral.find("modem", rednet.open)
    rednet.host("files", "turtle")
    if rednet.isOpen() == false then
        print("Could not open rednet")
    end
end

local function receive_file()
    repeat
        local id, data = rednet.receive("file_upload")
    until data == "download"

    fs.copy("disk/test.lua", "test.lua")
    turtle.up()
    fs.copy("test.lua", "disk2/startup.lua")
    turtle.down()
    turtle.select(2)
    turtle.place()
    --local content = file.readAll(data)
    --file.close()
    --print("Starting the received program!")
    --os.run({}, "startup.lua")
end

find_modem()
receive_file()