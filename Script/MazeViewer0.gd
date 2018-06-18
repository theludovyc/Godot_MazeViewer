extends Node

var Helper=preload("Helper.gd")
var Maze1=preload("Maze1.gd")

func _ready():
	var maze=Maze1.new(8, 8)

	randomize()

	maze.genMaze()

	for posX in range(0, maze.width):
		for posY in range(0, maze.height):
			var rM=maze.getCase(posX, posY)
			if rM!=null:
				var tl=$Tile.genWall(posX, posY)

				if Helper.vec2_compar(maze.startPos, posX, posY):
					tl.modulate=Color(0,1,0,1)

				if Helper.vec2_compar(maze.endPos, posX, posY):
					tl.modulate=Color(1, 0, 0, 1)

				if rM.dW:
					$Tile.genDoorWest(tl)

				if rM.dS:
					$Tile.genDoorSouth(tl)

	print(maze.startPos)
	print(maze.endPos)