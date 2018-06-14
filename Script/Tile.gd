extends Node

var GenTile=preload("res://Script/GenTile.gd")

var wall=preload("res://Prefab/Wall.tscn")
var door=preload("res://Prefab/Door.tscn")

func genWall(x, y):
	return GenTile.genTile(wall, self, x*32, y*32)

func genDoor(parent, x, y):
	GenTile.genTile(door, parent, x, y)

func genDoorNorth(parent):
	genDoor(parent, 0, 16)
	pass

func genDoorSouth(parent):
	genDoor(parent, 0, -16)
	pass

func genYDoor(parent, x, y):
	GenTile.genTileRot(door, parent, x, y, deg2rad(90))
	pass

func genDoorWest(parent):
	genYDoor(parent, -16, 0)
	pass

func genDoorEast(parent):
	genYDoor(parent, 16, 0)
	pass

func clear():
	for body in get_children():
		body.queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
