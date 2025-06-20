-- Computer Craft DC33 main computer sender and "grader" with screen
local puzzleString = "puzzle"
local selectedPuzzle = "1"

-- Get monitor and sizes
local monitor = nil
if peripheral.find("monitor") then
    monitor = peripheral.find("monitor")
else
    monitor = term.current()
end

if not monitor then
    error("Monitor not found?")
end

-- Basalt initialization stuff
local basalt = require("basalt")
local main = basalt.getMainFrame():setTerm(monitor)
local submitResetBox = main:addContainer()
local sendButton = submitResetBox:addButton()
local resetButton = submitResetBox:addButton()

-- Puzzle Selection Buttons
local puzzleSelect = main:addContainer()
local _puzzleLabel = puzzleSelect:addLabel():setText("Select Puzzle"):setPosition(3,1):setWidth("{self.text:len() + 1}")
local puzzle1Button = puzzleSelect:addButton()
puzzleSelect:setPosition(1,1):setSize("{parent.width}", "{ceil(parent.height/12)}"):setBackground(colors.lightGray)

puzzle1Button:setText("1")
local buttonWidth = puzzle1Button.text:len()+2
puzzle1Button:setSize(buttonWidth, 1):setPosition(3, 2):setBackground(colors.green)

local puzzleButtons = {puzzle1Button}

local width, height = monitor.getSize()
width = width - 2
height = height - 2

peripheral.find("modem", rednet.open)
rednet.host("files", "pc")

-- File Sending Logic
local function sendFile()
    local turtle = rednet.lookup("files", puzzleString..selectedPuzzle)
    if turtle == nil then
        print("Unable to locate the receiver!")
        return false
    end

    -- TODO: File Picker
    local file = fs.open("testfile.lua", "r")
    if file then
        local data = file.readAll()
        if not data then

            return
        end
        file.close()
        rednet.send(turtle, data, "file_upload")
    end
end

-- Reset Logic
local function sendReset()
    local receiver = rednet.lookup("reset", puzzleString..selectedPuzzle)
    if not receiver then
        error("Receiver not found " .. receiver)
        resetButton:setText("Error!!")
        return
    end
    rednet.send(receiver, "", "reset")
    resetButton:setText("Reset!")
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

local currentX = 3
local currentY = 2
local function selectPuzzleButton(element) 
    puzzleButtons[tonumber(selectedPuzzle)]:setBackground(colors.gray)
    element:setBackground(colors.green)
    selectedPuzzle = element:getText()
end

-- Creates interactable puzzle upload buttons
for i = 0, 8 do
    local button = puzzleSelect:addButton():setSize(buttonWidth, 1):setBackground(colors.gray)
    button:setText(tostring(i+2))
    currentX = currentX + buttonWidth
    if currentX > width then
        currentX = 3
        currentY = currentY + 1
        puzzleSelect:setHeight(currentY)
    end
    button:setPosition(currentX, currentY)
    table.insert(puzzleButtons, button)
end

for i, button in pairs(puzzleButtons) do
    button:onClick(selectPuzzleButton)
end


-- File Picker frame initilization
local fileFrame = main:addFrame()
local textContainer = fileFrame:addContainer()
local fileContainer = fileFrame:addContainer()

local fileText = textContainer:addLabel()
local fileList = fileContainer:addList()

--  file picker parent frame sizing
fileFrame:setSize("{parent.width - 4}", "{ ceil(parent.height / 2) }"):setPosition(3, "{ floor(parent.height/3) - 1 }"):setBackground(colors.lightGray)
border(fileFrame, colors.gray)

-- frame that holds the text & container that holds list
-- 2 is for the border, which totally exists I promise
textContainer:setSize("{ parent.width - 2 }", "{ floor(parent.height / 8) }"):setPosition(2, 2):setBackground(colors.lightGray):prioritize()
local _contX, contY = textContainer:getSize()
local _posX, posY = textContainer:getRelativePosition()
fileContainer:setSize("{ parent.width - 2 }", "{4 * ceil(parent.height / 6) - 2}"):setPosition(2, posY+contY+1)

-- The actual text
fileText:setText("Select a file")
fileList:setSize("{ parent.width }", "{ parent.height }")

-- Frame that holds the selectable list, and the list itself
for _k,v in pairs(list_files()) do
    fileList:addItem(v)
end

-- Button Initialization stuff
submitResetBox:setSize("{parent.width}", "{ceil(parent.height / 6)}"):setPosition(1, "{parent.height-2}")
sendButton:setSize("{ ceil(parent.width/4) }", 1):setPosition("{ parent.width - self.width - 2 }", "{ parent.height - 2 }"):setText("Send"):setBackground(colors.green)
sendButton:onClick(function(element)
    sendFile()
    sendButton:setText("Sent!")
end)

resetButton:setSize("{ ceil(parent.width/4) }", 1):setPosition(3, "{ parent.height - 2 }"):setText("Reset"):setBackground(colors.red)
resetButton:onClick(function(element)
    sendReset()
end)

basalt.run()