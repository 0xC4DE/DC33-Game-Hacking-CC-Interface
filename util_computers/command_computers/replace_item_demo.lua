local x,y,z = commands.getBlockPosition()
local info = commands.getBlockInfo(x, y+2, z)
if info["name"] ~= "minecraft:air" then
    if info["nbt"]["Items"][1]["id"] ~= "minecraft:coal" then
    commands.exec("/item replace block ~ ~2 ~ container.0 with minecraft:coal 64")
    sleep(1)
    end
end