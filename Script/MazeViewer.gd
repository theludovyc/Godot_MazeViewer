extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var helper=preload("res://Script/Helper.gd")

var mapW=16
var mapH=16

var maze = []

var genState=0

var posX=0
var posY=0

var probDoor=0.55

var pathLength=0
var minPathLength=int(0.25*mapW*mapH)
var maxPathLength=int(0.5*mapW*mapH)

var exs = []

class Room:
	var dN=false
	var dE=false
	var dS=false
	var dW=false
	var id=0
	var wL

	func haveCon():
		if dN:
			return true
		if dE:
			return true
		if dS:
			return true
		if dW:
			return true
		return false

func getCase(posX, posY):
	return maze[posY*mapW+posX]

func setCase(posX, posY, b):
	maze[posY*mapW+posX]=b

func remCase(posX, posY):
	maze[posY*mapW+posX]=null

func mazeInit():
	maze.resize(mapW*mapH)

	randomize()

	posX=helper.rand_between(0, mapW-1)
	posY=helper.rand_between(0, mapH-1)

	exs[0]=Vector2(posX, posY)

	pathLength=0

	var rm=Room.new()

	rm.wL=$Tile.genWall(posX, posY)
	rm.wL.modulate=Color(0,1,0,1)
	rm.id=3
	
	setCase(posX, posY, rm)
	
	pass

func genPath():
	var ar1 = []

	if posX+1<mapW and getCase(posX+1, posY)==null:
		ar1.append(0)

	if posY+1<mapH and getCase(posX, posY+1)==null:
		ar1.append(1)

	if posX-1>=0 and getCase(posX-1, posY)==null:
		ar1.append(2)

	if posY-1>=0 and getCase(posX, posY-1)==null:
		ar1.append(3)

	if ar1.size()==0:
		print("pathLength: ", pathLength)

		if pathLength>=minPathLength and pathLength<=maxPathLength:
			genState=1

			var rm=getCase(posX, posY)
			rm.id=3
			rm.wL.modulate=Color(1, 0, 0, 1)

			posX=0
			posY=0

			return
		else:
			$Tile.clear()

			maze.clear()
			
			mazeInit()
			return

	var rm=Room.new()

	match ar1[ helper.rand_between(0, ar1.size()-1 ) ]:
		0:
			var rm1=getCase(posX, posY)
			$Tile.genDoorEast(rm1.wL)
			rm1.dE=true
			rm.dW=true
			posX=posX+1
		1:
			var rm1=getCase(posX, posY)
			$Tile.genDoorNorth(rm1.wL)
			rm1.dN=true
			rm.dS=true
			posY=posY+1
		2:
			var rm1=getCase(posX, posY)
			$Tile.genDoorWest(rm1.wL)
			rm1.dW=true
			rm.dE=true
			posX=posX-1
		3:
			var rm1=getCase(posX, posY)
			$Tile.genDoorSouth(rm1.wL)
			rm1.dS=true
			rm.dN=true
			posY=posY-1

	rm.wL=$Tile.genWall(posX, posY)
	rm.id=2
	setCase(posX, posY, rm)

	pathLength=pathLength+1
	pass

func genOther():
	if getCase(posX, posY)==null:
		var rm=Room.new()

		rm.wL=$Tile.genWall(posX, posY)
		rm.wL.modulate=Color(0.67,0.67,0.67,1)

		setCase(posX, posY, rm)

		#door West
		if posX>0 and randf()>probDoor:
			getCase(posX-1, posY).dE=true
			rm.dW=true
			$Tile.genDoorWest(rm.wL)

		#door East
		if posX<mapW-1 and randf()>probDoor:
			var rmTmp=getCase(posX+1, posY)
			if rmTmp!=null:
				rmTmp.dW=true
				rm.dE=true
				$Tile.genDoorEast(rm.wL)

		#door South
		if posY>0 and randf()>probDoor:
			getCase(posX, posY-1).dN=true
			rm.dS=true
			$Tile.genDoorSouth(rm.wL)

		#door North
		if posY<mapH-1 and randf()>probDoor:
			var rmTmp=getCase(posX, posY+1)
			if rmTmp!=null:
				rmTmp.dS=true
				rm.dN=true
				$Tile.genDoorNorth(rm.wL)

	if posY==mapH-1 and posX==mapW-1:
		genState=2
		return

	if posX==mapW-1:
		posY=posY+1
		posX=0
	else:
		posX=posX+1
	pass

func cleanOther():
	for posY in range(0, mapH):
		for posX in range(0, mapW):
			var rm=getCase(posX, posY)
			if rm.id==0 and rm.haveCon()==false:
				rm.wL.queue_free()
				remCase(posX, posY)
	genState=3
	pass

func explore():
	var sz = exs.size()

	if sz==0:
		genState=4
		return

	var i=0
	for j in range(0, sz):
		var haveMove=false

		var pX=exs[i].x
		var pY=exs[i].y

		var rm=getCase(pX, pY)

		if rm.dN:
			var rm1=getCase(pX, pY+1)
			if rm1.id!=3:
				rm1.wL.modulate=Color(0, 0.65, 1, 1)
				rm1.id=3
				exs[i].y=pY+1
				haveMove=true
		
		
		if rm.dW:
			var rm1=getCase(pX-1, pY)
			if rm1.id!=3:
				rm1.wL.modulate=Color(0, 0.65, 1, 1)
				rm1.id=3
				if haveMove:
					exs.append(Vector2(pX-1, pY))
				else:
					exs[i].x=pX-1
					haveMove=true
		
		if rm.dS:
			var rm1=getCase(pX, pY-1)
			if rm1.id!=3:
				rm1.wL.modulate=Color(0, 0.65, 1, 1)
				rm1.id=3
				if haveMove:
					exs.append(Vector2(pX, pY-1))
				else:
					exs[i].y=pY-1
					haveMove=true

		if rm.dE:
			var rm1=getCase(pX+1, pY)
			if rm1.id!=3:
				rm1.wL.modulate=Color(0, 0.65, 1, 1)
				rm1.id=3
				if haveMove:
					exs.append(Vector2(pX+1, pY))
				else:
					exs[i].x=pX+1
					haveMove=true
		
		if !haveMove:
			exs.remove(i)
		else:
			i=i+1

func lastClean():
	for posY in range(0, mapH):
		for posX in range(0, mapW):
			var rm=getCase(posX, posY)
			if rm!=null and rm.id!=3:
				rm.wL.queue_free()
				remCase(posX, posY)
	$Timer.stop()
	pass

func genMaze():
	match genState:
		0:
			genPath()
		1:
			genOther()
		2:
			cleanOther()
		3:
			explore()
		4:
			lastClean()
	pass

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	exs.append(Vector2(0, 0))

	mazeInit()
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if $Timer.is_stopped() and Input.is_action_pressed("ui_left"):
		$Timer.start()
	pass
