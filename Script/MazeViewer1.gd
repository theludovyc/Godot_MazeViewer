extends Node

#le nord c'est vers y+ sois le bas

var helper=preload("res://Script/Helper.gd")
var Tab2d=preload("Tab2d.gd")

var mapW=8
var mapH=8

var maze = Tab2d.new(mapW, mapH)

var genState=0

var posX=0
var posY=0

var probDoor=0.55

var pathLength=0
var minPathLength=int(0.25*mapW*mapH)
var maxPathLength=int(0.5*mapW*mapH)

var exs=[]

var startPos=Vector2(0, 0)
var endPos=Vector2(0, 0)

class Room:
	var dW=false
	var dS=false

class DataRoom:
	var room=Room.new()
	var id=0
	var wL

func mazeInit():
	pathLength=0

	randomize()

	posX=helper.rand_between(0, mapW-1)
	posY=helper.rand_between(0, mapH-1)

	exs[0]=Vector2(posX, posY)
	startPos=Vector2(posX, posY)

	var dR=DataRoom.new()

	dR.wL=$Tile.genWall(posX, posY)
	dR.wL.modulate=Color(0,1,0,1)
	dR.id=3

	maze.setCase(posX, posY, dR)
	pass

func genPath():
	var ar1 = []

	#West
	if posX-1>=0 and maze.isNull(posX-1, posY):
		ar1.append(0)

	#South
	if posY>0 and maze.isNull(posX, posY-1):
		ar1.append(1)

	#East
	if posX+1<mapW and maze.isNull(posX+1, posY):
		ar1.append(2)

	#North
	if posY<mapH-1 and maze.isNull(posX, posY+1):
		ar1.append(3)

	var sz=ar1.size()

	if sz==0:
		print("pathLength: ", pathLength)

		if pathLength>=minPathLength:
			genState=1

			var dR=maze.getCase(posX, posY)
			dR.id=3
			dR.wL.modulate=Color(1, 0, 0, 1)

			endPos=Vector2(posX, posY)

			posX=0
			posY=0

			return
		else:
			$Tile.clear()

			maze.clear()
			
			mazeInit()
			return

	var dR=DataRoom.new()
	var current=maze.getCase(posX, posY)

	match ar1[ helper.rand_between(0, sz-1 ) ]:
		0:
			$Tile.genDoorWest(current.wL)
			current.room.dW=true
			posX-=1
		1:
			$Tile.genDoorSouth(current.wL)
			current.room.dS=true
			posY-=1
		2:
			$Tile.genDoorEast(current.wL)
			dR.room.dW=true
			posX+=1
		3:
			$Tile.genDoorNorth(current.wL)
			dR.room.dS=true
			posY+=1

	dR.wL=$Tile.genWall(posX, posY)

	pathLength+=1

	if pathLength>=minPathLength:
		dR.id=3
		dR.wL.modulate=Color(1, 0, 0, 1)

		endPos=Vector2(posX, posY)

		genState=1
	else:
		dR.id=2

	maze.setCase(posX, posY, dR)
	pass

func genOtherX():
	if maze.getCase(posX, posY)==null:
		var dR=DataRoom.new()

		dR.wL=$Tile.genWall(posX, posY)
		dR.wL.modulate=Color(0.67,0.67,0.67,1)

		if randf()>probDoor:
			dR.room.dW=true
			$Tile.genDoorWest(dR.wL)

		if posX<mapW-1:
			var dR1=maze.getCase(posX+1, posY)
			if dR1!=null and randf()>probDoor:
				dR1.room.dW=true
				$Tile.genDoorWest(dR1.wL)

		maze.setCase(posX, posY, dR)

	if posX==mapW-1:
		posX=0
		posY=1
		genState=3
		return

	posX+=1
	pass

func genOtherY():
	if maze.getCase(posX, posY)==null:
		var dR=DataRoom.new()

		dR.wL=$Tile.genWall(posX, posY)
		dR.wL.modulate=Color(0.67,0.67,0.67,1)

		if randf()>probDoor:
			dR.room.dS=true
			$Tile.genDoorSouth(dR.wL)

		if posY<mapH-1:
			var dR1=maze.getCase(posX, posY+1)
			if dR1!=null and randf()>probDoor:
				dR1.room.dS=true
				$Tile.genDoorSouth(dR1.wL)

		maze.setCase(posX, posY, dR)

	if posY==mapH-1:
		posX=1
		posY=1
		genState=4
		return

	posY+=1
	pass

func genOther():
	if maze.getCase(posX, posY)==null:
		var dR=DataRoom.new()

		dR.wL=$Tile.genWall(posX, posY)
		dR.wL.modulate=Color(0.67,0.67,0.67,1)

		if randf()>probDoor:
			dR.room.dW=true
			$Tile.genDoorWest(dR.wL)

		if randf()>probDoor:
			dR.room.dS=true
			$Tile.genDoorSouth(dR.wL)

		if posX<mapW-1:
			var dR1=maze.getCase(posX+1, posY)
			if dR1!=null and randf()>probDoor:
				dR1.room.dW=true
				$Tile.genDoorWest(dR1.wL)

		if posY<mapH-1:
			var dR1=maze.getCase(posX, posY+1)
			if dR1!=null and randf()>probDoor:
				dR1.room.dS=true
				$Tile.genDoorSouth(dR1.wL)

		maze.setCase(posX, posY, dR)

	if posY==mapH-1 and posX==mapW-1:
		genState=5
		return

	if posX==mapW-1:
		posY=posY+1
		posX=0
	else:
		posX=posX+1
	pass

func explore():
	var sz = exs.size()

	if sz==0:
		genState=6
		return

	var i=0
	for j in range(0, sz):
		var haveMove=false

		var pX=exs[i].x
		var pY=exs[i].y

		var rm=maze.getCase(pX, pY).room

		if rm.dW:
			var dR=maze.getCase(pX-1, pY)
			if dR.id!=3:
				dR.wL.modulate=Color(0, 0.65, 1, 1)
				dR.id=3
				exs[i].x=pX-1
				haveMove=true

		if rm.dS:
			var dR=maze.getCase(pX, pY-1)
			if dR.id!=3:
				dR.wL.modulate=Color(0, 0.65, 1, 1)
				dR.id=3
				if haveMove:
					exs.append(Vector2(pX, pY-1))
				else:
					exs[i].y=pY-1
					haveMove=true

		if pX<mapW-1:
			var dR=maze.getCase(pX+1, pY)
			if dR!=null and dR.room.dW and dR.id!=3:
				dR.wL.modulate=Color(0, 0.65, 1, 1)
				dR.id=3
				if haveMove:
					exs.append(Vector2(pX+1, pY))
				else:
					exs[i].x=pX+1
					haveMove=true

		if pY<mapH-1:
			var dR=maze.getCase(pX, pY+1)
			if dR!=null and dR.room.dS and dR.id!=3:
				dR.wL.modulate=Color(0, 0.65, 1, 1)
				dR.id=3
				if haveMove:
					exs.append(Vector2(pX, pY+1))
				else:
					exs[i].y=pY+1
					haveMove=true
		
		if !haveMove:
			exs.remove(i)
		else:
			i=i+1

func clean():
	for posY in range(0, mapH):
		for posX in range(0, mapW):
			var dR=maze.getCase(posX, posY)
			if dR.id!=3:
				dR.wL.queue_free()
				maze.nullCase(posX, posY)

	var dR=maze.getCase(endPos.x, endPos.y)
	if dR.room.dW and maze.isNull(endPos.x-1, endPos.y):
		dR.room.dW=false
		dR.wL.get_child(0).queue_free()

	if dR.room.dS and maze.isNull(endPos.x, endPos.y-1):
		dR.room.dS=false
		if dR.wL.get_child_count()>1:
			dR.wL.get_child(1).queue_free()
		else:
			dR.wL.get_child(0).queue_free()

	$Timer.stop()

func genMaze():
	match genState:
		0:
			genPath()
		1:
			if maze.isNull(0, 0):
				var dR=DataRoom.new()

				dR.wL=$Tile.genWall(0, 0)
				dR.wL.modulate=Color(0.67,0.67,0.67,1)

				maze.setCase(0, 0, dR)

			posX=1
			posY=0

			genState=2
		2:
			genOtherX()
		3:
			genOtherY()
		4:
			genOther()
		5:
			explore()
		6:
			clean()
	pass

func _ready():
	exs.append(Vector2(0, 0))

	mazeInit()
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if $Timer.is_stopped() and Input.is_action_pressed("ui_left"):
		$Timer.start()
	pass