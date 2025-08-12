--[[
Based upon the label on the puter, start up the proper file that is stored in the command module of the rom
This makes the datapack required, but allows for a generalized startup script!
]]--

local label = os.getComputerLabel()
shell.execute("/rom/modules/command/"..label..".lua")