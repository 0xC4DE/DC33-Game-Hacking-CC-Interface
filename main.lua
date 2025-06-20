-- !! CHANGEME !!
local puzzle_label = "puzzle1"

-- Computer Craft DC33 main computer sender and "grader" with screen
local basalt = require("basalt")

-- Get monitor and sizes
local monitor = nil
if peripheral.find("monitor") then
    monitor = peripheral.find("monitor")
else
    monitor = term.current()
end
width, height = monitor.getSize()
width = width - 2
height = height - 2

peripheral.find("modem", rednet.open)
rednet.host("files", "pc")

-- File Sending Logic
local function send_file()
    local turtle = rednet.lookup("files", puzzle_label)
    if turtle == nil then
        print("Unable to locate the receiver!")
        return false
    end

    -- TODO: File Picker
    local file = fs.open("testfile.lua", "r")
    local data = file.readAll()
    file.close()
    rednet.send(turtle, data, "file_upload")
end

local colorHex = {}
for i = 0, 15 do
    colorHex[2^i] = ("%x"):format(i)
    colorHex[("%x"):format(i)] = 2^i
end

--- This is the border function, it takes the element and the color of the border as arguments
--- @param element Element The element to add the border to
--- @param borderColor number The color of the border
local function border(element, borderColor)
    local canvas = element:getCanvas()
    canvas:addCommand(function(self)
        local width, height = self.get("width"), self.get("height")
        width = math.floor(width)
        height = math.floor(height)
        local bg = self.get("background")
        -- Lines:
        self:textFg(1, 1, ("\131"):rep(width), borderColor)
        self:multiBlit(1, height, width, 1, "\143", colorHex[bg], colorHex[borderColor])
        self:multiBlit(1, 1, 1, height, "\149", colorHex[borderColor], colorHex[bg])
        self:multiBlit(width, 1, 1, height, "\149", colorHex[bg], colorHex[borderColor])

        -- Corners:
        self:blit(1, 1, "\151", colorHex[borderColor], colorHex[bg])
        self:blit(width, 1, "\148", colorHex[bg], colorHex[borderColor])
        self:blit(1, height, "\138", colorHex[bg], colorHex[borderColor])
        self:blit(width, height, "\133", colorHex[bg], colorHex[borderColor])
    end)
end


local function list_files()
    local files = fs.list("/")
    local ret_files = {}
    for k, v in pairs(files) do
        if v:sub(-3) == "lua" then
            table.insert(ret_files, v)
        end
    end
    return ret_files
end

-- Create the main frame
local main = basalt.createFrame():setTerm(monitor)

-- Puzzle Selection Buttons
local puzzle_select = main:addContainer()
puzzle_select:setPosition(1,1):setSize("{parent.width}", 2):setBackground(colors.lightGray)
local puzzle_label = puzzle_select:addLabel():setText("Select Puzzle"):setPosition(1,1):setWidth("{self.text:len() + 1}")
local puzzle1_button = puzzle_select:addButton()
puzzle1_button:setText("1")
local button_width = puzzle1_button.text:len()+2
puzzle1_button:setSize(button_width, 1):setPosition(1, 2):setBackground(colors.green)

local puzzle_buttons = {puzzle1_button}
local current_x = 1
local current_y = 2
local current_row = 1
for i = 0, 8 do
    local button = puzzle_select:addButton():setSize(button_width, 1):setBackground(colors.gray)
    button:setText(tostring(i+2))
    current_x = current_x + button_width
    if current_x > width then
        current_x = 1
        current_y = current_y + 1
        puzzle_select:setHeight(current_y)
    end
    button:setPosition(current_x, current_y)
    table.insert(puzzle_buttons, button)
end

-- File Picker frame
local file_frame = main:addFrame()
local text_container = file_frame:addContainer()
local file_container = file_frame:addContainer()

local file_text = text_container:addLabel()
local file_list = file_container:addList()

-- parent frame
file_frame:setSize("{parent.width - 4}", "{ ceil(parent.height / 2) }"):setPosition(3, "{ floor(parent.height/3) - 1 }"):setBackground(colors.lightGray)
border(file_frame, colors.gray)

-- frame that holds the text & container that holds list
-- 2 is for the border, which totally exists I promise
text_container:setSize("{ parent.width - 2 }", "{ floor(parent.height / 8) }"):setPosition(2, 2):setBackground(colors.lightGray):prioritize()
contX, contY = text_container:getSize()
posX, posY = text_container:getRelativePosition()
file_container:setSize("{ parent.width - 2 }", "{4 * ceil(parent.height / 6) - 2 }"):setPosition(2, posY+contY+1)

-- The actual text
file_text:setText("Select a file")
file_list:setSize("{ parent.width }", "{ parent.height }")

-- Frame that holds the selectable list, and the list itself
for k,v in pairs(list_files()) do
    file_list:addItem(v)
end

-- Button Init
local send_button = basalt.create("Button")
main:addChild(send_button)
send_button:setSize("{ ceil(parent.width/3) }", 3):setPosition("{parent.width - ceil(parent.width/3) - 1}", "{parent.height - 3}"):setText("Send"):setBackground(colors.green)
send_button:onClick(function(element)
    send_file()
    send_button:setText("Sent!")
end)

local reset_button = basalt.create("Button")
main:addChild(reset_button)
reset_button:setSize("{ ceil(parent.width/3) }", 3):setPosition(3, "{parent.height - 3}"):setText("Reset"):setBackground(colors.red)
reset_button:onClick(function(element)
    receiver = rednet.lookup("reset", puzzle_label)
    if not receiver then
        error("Receiver not found " .. receiver)
        reset_button:setText("Error!!")
        return
    end
    rednet.send(receiver, "", "reset")
    reset_button:setText("Reset!")
end)

basalt.run()