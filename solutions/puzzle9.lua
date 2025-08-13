-- This one has several bad solutions and a couple easy/elegant ones. This is somewhere in between

turtle.forward()

function ironBlock()
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
end

function goldBlock()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    turtle.forward()
    turtle.forward()

end

-- This loop can be run either 20 or so times, or if the player is clever they can observe for green concrete

r, underBlock = turtle.inspectDown()
while r and underBlock.name ~= "minecraft:green_concrete" do
    ret, block = turtle.inspect()
    if block.name == "minecraft:iron_block" then
        ironBlock()
    elseif block.name == "minecraft:gold_block" then
        goldBlock()
    end
    r, underBlock = turtle.inspectDown()
end
