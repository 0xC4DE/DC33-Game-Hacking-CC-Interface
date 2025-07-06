-- Computer Craft DC33 main computer sender and "grader" with screen
local puzzleString = "puzzle"
local selectedPuzzle = "1"
local filesHosts = {}
local selectedFile

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
local activePuzzles = {true, false, false, false, false, false, false, false, false, false}

-- File Picker frame initilization
local fileFrame = main:addFrame()
local textContainer = fileFrame:addContainer()
local fileContainer = fileFrame:addContainer()

local fileText = textContainer:addLabel()
local fileList = fileContainer:addList()

-- Back to puzzle select
puzzleSelect:setPosition(1,1):setSize("{parent.width}", "{ceil(parent.height/12)}"):setBackground(colors.lightGray)
puzzle1Button:setText("1")
local buttonWidth = puzzle1Button.text:len()+2
puzzle1Button:setSize(buttonWidth, 1):setPosition(3, 2):setBackground(colors.green)

local puzzleButtons = {puzzle1Button}

local width, height = monitor.getSize()
width = width - 2
height = height - 2

peripheral.find("modem", rednet.open)

-- File Sending Logic
local sendButtonEnabled = true
local sendTimerId = nil
local function sendFile()
    if not sendButtonEnabled then 
        return
    end

    sendButton:setText("Sending..."):setBackground(colors.gray):setWidth("{self.text:len()+2}")
    sendButtonEnabled = false

    local computer = filesHosts[selectedPuzzle]
    if computer == nil then
        sendButton:setText("Error!"):setBackground(colors.red):setWidth("{self.text:len()+2}")
        sendTimerId = os.startTimer(3)
        return
    end

    -- Probably guaranteed to be a file, whatever, lol.
    if fileList:getSelectedItem() then
        local file = fs.open(fileList:getSelectedItem()["text"], "r")
        local data = file.readAll()
        if not data then
            sendButton:setText("File Error!"):setBackground(colors.red)
            sendTimerId = os.startTimer(3)
            file.close()
            return
        end
        file.close()
        rednet.send(computer, data, "files")
    else
        sendButton:setText("Select a file!"):setWidth("{self.text:len()+2}"):setBackground(colors.red)
        sendTimerId = os.startTimer(3)
    end

    sendButton:setText("Sent!"):setBackground(colors.green)
    sendTimerId = os.startTimer(3)
end

-- Reset Logic
local resetTimerId = nil -- impossible start number
local resetButtonEnabled = true
local function sendReset()
    if not resetButtonEnabled then
        return
    end
    resetButton:setText("Sending...")
    resetButton:setBackground(colors.gray)
    local receiver = filesHosts[selectedPuzzle]
    if not receiver then
        resetButton:setText("Error!"):setBackground(colors.red)
        resetTimerId = os.startTimer(3)
        return
    end
    rednet.send(receiver, "", "reset")
    resetButton:setText("Reset!")
    resetButtonEnabled = false
    resetTimerId = os.startTimer(3)
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
            if v:sub(1,4) == "main" or v:sub(1,7) == "rawterm" or v:sub(1,6) == "basalt" then
            else
                table.insert(ret_files, v)
            end
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
    local button = puzzleSelect:addButton():setSize(0,0):setBackground(colors.gray)
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
    if sendFile() then
        sendButton:setText("Sent!")
    end
end)

resetButton:setSize("{ ceil(parent.width/4) }", 1):setPosition(3, "{ parent.height - 2 }"):setText("Reset"):setBackground(colors.red)
resetButton:onClick(function(element)
    sendReset()
end)

function resetTextEvent()
    while true do
        local event = nil
        local event, id = os.pullEvent()
        if event == "timer" then
            if id == resetTimerId then
                resetButton:setText("Reset"):setBackground(colors.red)
                resetButtonEnabled = true
            elseif id == sendTimerId then
                sendButton:setText("Send"):setBackground(colors.green):setWidth("{ ceil(parent.width)/4 }")
                sendButtonEnabled = true
            end
        end
    end
end

function receiveRednet()
    while true do
        local id, message = rednet.receive("puzzleResponse")
        if type(message) ~= "table" then
            return
        end
        for idx, id in ipairs(message) do
            --print(id)
            if id+1 == 11 then
                break
            end
            if activePuzzles[id+1] == false then
                puzzleButtons[id+1]:setSize(buttonWidth, 1)
            end
            activePuzzles[id+1] = true
            --print(textutils.serialize(activePuzzles))
        end
    end
end

function askPuzzles()
    local controlPC
    while true do
        if not controlPC then
            controlPC = rednet.lookup("puzzleRequest", "controlpc")
        else
            rednet.send(controlPC, "please :)", "puzzleRequest")
        end
        sleep(1)
    end
end

function rednetComputers()
    local funcs = {}
    for i=1, 10 do
        local f = (function() filesHosts[tostring(i)] = rednet.lookup("files", "puzzle"..i) end)
        table.insert(funcs, f)
    end
    parallel.waitForAll(unpack(funcs))
end

print("Loading...")
rednetComputers()

parallel.waitForAny(resetTextEvent, receiveRednet, askPuzzles, basalt.run)