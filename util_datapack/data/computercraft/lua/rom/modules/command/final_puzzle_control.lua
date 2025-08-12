while true do
    local _, text = commands.exec("scoreboard players get @r puzzle6")
    if text ~= nil and string.find(text[1], "has 1") then
        _, text = commands.exec("scoreboard players get @r puzzle7")
        if text ~= nil and string.find(text[1], "has 1") then
            _, text = commands.exec("scoreboard players get @r puzzle8")
            if text ~= nil and string.find(text[1], "has 1") then
                _, text = commands.exec("scoreboard players get @r puzzle9")
                if text ~= nil and string.find(text[1], "has 1") then
                    commands.exec("scoreboard players set @r puzzle10 1")
                end
            end
        end
    end
    sleep(1)
end