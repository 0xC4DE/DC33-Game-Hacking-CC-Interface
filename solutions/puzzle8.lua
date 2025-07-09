turtle.turnRight()

-- This works because it just populates the inventory
for i=1, 6 do
    turtle.suck()
end

-- We know there's 6 slots occupied because there's 6 blocks (told by the board)
local colors = {"red", "green", "purple", "yellow", "orange", "cyan"}
local colorSlots = {nil, nil, nil, nil, nil, nil}

-- This isn't something I expect somebody to come up with, I expect an IF tree
for slot=1, #colors do
    for i=1, #colors do -- 1 to 6, because colors is 6 long
        if string.find(turtle.getItemDetail(slot).name, colors[i]) then
            colorSlots[i] = slot
        end
    end
end

-- There's better ways to sequence this, I didn't do that.
turtle.turnLeft()
turtle.forward()
turtle.select(colorSlots[2]) -- green
turtle.drop()
turtle.up()
turtle.up()
turtle.select(colorSlots[1]) -- red
turtle.drop()
turtle.turnRight()
turtle.forward()
turtle.forward()
turtle.forward()
turtle.turnLeft()
turtle.select(colorSlots[3]) -- purple
turtle.drop()
turtle.down()
turtle.down()
turtle.select(colorSlots[4]) -- yellow
turtle.drop()
turtle.turnRight()
turtle.forward()
turtle.forward()
turtle.forward()
turtle.turnLeft()
turtle.select(colorSlots[6]) -- cyan
turtle.drop()
turtle.up()
turtle.up()
turtle.select(colorSlots[5]) -- orange
turtle.drop()