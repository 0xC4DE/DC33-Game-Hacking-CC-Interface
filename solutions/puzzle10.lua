-- This puzzle is mostly lengthy, honestly probably shorter than some others, I expect at this stage
-- Somebody would potentially make their own movement sequencer, so that they can make a string like:
-- "ffubb" for "forward forward up back back"
turtle.suckUp()
turtle.turnLeft()
turtle.forward()
turtle.turnRight()
turtle.up()
turtle.up()
turtle.forward()
redstone.setOutput("front", true) -- power the last piston
sleep(1)
turtle.down()
turtle.down()
turtle.back()
turtle.turnLeft()
turtle.forward()
turtle.forward()
turtle.turnRight()
turtle.place() -- place first block
turtle.turnLeft()
turtle.forward()
turtle.forward()
turtle.up()
turtle.turnRight()
turtle.drop(1) -- place block in chest
turtle.down()
turtle.turnLeft()
turtle.forward()
turtle.forward()
turtle.turnRight()
turtle.up()
turtle.up()
turtle.place() -- place in frame
turtle.down()
turtle.down()
turtle.turnLeft()
turtle.forward()
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.forward()
turtle.forward()
turtle.place() -- Place lever