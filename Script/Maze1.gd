extends "Tab2d.gd"
#le nord c'est vers y+ sois le bas

var helper=preload("res://Script/Helper.gd")

class Room:
	var dW=false
	var dS=false
	var valid=false

var probDoor=0.55

var minPathLength=0
var maxPathLength=0

var startPos=Vector2(0, 0)
var endPos=Vector2(0, 0)

func _init(w, h).(w, h):
	minPathLength=int(0.25*w*h)
	maxPathLength=int(0.5*w*h)

func mazeInit():
	startPos=Vector2(helper.rand_between(0, width-1), helper.rand_between(0, height-1))

	var rM=Room.new()

	setCase(startPos.x, startPos.y, rM)
	pass

func genPath():
	var pathLength=0
	var posX=startPos.x
	var posY=startPos.y

	while true:
		var ar1 = []

		#West
		if posX>0 and isNull(posX-1, posY):
			ar1.append(0)

		#South
		if posY>0 and isNull(posX, posY-1):
			ar1.append(1)

		#East
		if posX<width-1 and isNull(posX+1, posY):
			ar1.append(2)

		#North
		if posY<height-1 and isNull(posX, posY+1):
			ar1.append(3)

		var sz=ar1.size()

		if sz==0:
			if pathLength>=minPathLength:
				var rM=getCase(posX, posY)
				rM.valid=true

				endPos=Vector2(posX, posY)

				return
			else:
				clear()
				
				mazeInit()

				pathLength=0
				posX=startPos.x
				posY=startPos.y

				continue

		var rM=Room.new()

		var current=getCase(posX, posY)

		match ar1[ helper.rand_between(0, sz-1 ) ]:
			0:
				current.dW=true
				posX-=1
			1:
				current.dS=true
				posY-=1
			2:
				rM.dW=true
				posX+=1
			3:
				rM.dS=true
				posY+=1

		pathLength+=1

		setCase(posX, posY, rM)

		if pathLength>=minPathLength:
			rM.valid=true

			endPos=Vector2(posX, posY)

			return
	pass

func genOtherX():
	for posX in range(1, width):
		if getCase(posX, 0)==null:
			var rM=Room.new()

			if randf()>probDoor:
				rM.dW=true

			if posX<width-1:
				var rM1=getCase(posX+1, 0)
				if rM1!=null and randf()>probDoor:
					rM1.dW=true

			setCase(posX, 0, rM)
	pass

func genOtherY():
	for posY in range(1, height):
		if getCase(0, posY)==null:
			var rM=Room.new()

			if randf()>probDoor:
				rM.dS=true

			if posY<height-1:
				var rM1=getCase(0, posY+1)
				if rM1!=null and randf()>probDoor:
					rM1.dS=true

			setCase(0, posY, rM)
	pass

func genOther():
	for posY in range(1, height):
		for posX in range(1, width):
			if getCase(posX, posY)==null:
				var rM=Room.new()

				if randf()>probDoor:
					rM.dW=true

				if randf()>probDoor:
					rM.dS=true

				if posX<width-1:
					var rM1=getCase(posX+1, posY)
					if rM1!=null and randf()>probDoor:
						rM1.dW=true

				if posY<height-1:
					var rM1=getCase(posX, posY+1)
					if rM1!=null and randf()>probDoor:
						rM1.dS=true

				setCase(posX, posY, rM)
	pass

func explore():
	var exs=[]
	exs.append(startPos)

	var sz=1
	while sz>0:
		var i=0
		for j in range(0, sz):
			var haveMove=false

			var pX=exs[i].x
			var pY=exs[i].y

			var rM=getCase(pX, pY)

			if rM.dW:
				var rM1=getCase(pX-1, pY)
				if !rM1.valid:
					rM1.valid=true
					exs[i].x=pX-1
					haveMove=true

			if rM.dS:
				var rM1=getCase(pX, pY-1)
				if !rM1.valid:
					rM1.valid=true
					if haveMove:
						exs.append(Vector2(pX, pY-1))
					else:
						exs[i].y=pY-1
						haveMove=true

			if pX<width-1:
				var rM1=getCase(pX+1, pY)
				if rM1!=null and rM1.dW and !rM1.valid:
					rM1.valid=true
					if haveMove:
						exs.append(Vector2(pX+1, pY))
					else:
						exs[i].x=pX+1
						haveMove=true

			if pY<height-1:
				var rM1=getCase(pX, pY+1)
				if rM1!=null and rM1.dS and !rM1.valid:
					rM1.valid=true
					if haveMove:
						exs.append(Vector2(pX, pY+1))
					else:
						exs[i].y=pY+1
						haveMove=true
			
			if !haveMove:
				exs.remove(i)
			else:
				i=i+1

		sz=exs.size()
	pass

func clean():
	for posY in range(0, height):
		for posX in range(0, width):
			var rM=getCase(posX, posY)
			if !rM.valid:
				nullCase(posX, posY)

	var rM=getCase(endPos.x, endPos.y)
	if rM.dW and isNull(endPos.x-1, endPos.y):
		rM.dW=false

	if rM.dS and isNull(endPos.x, endPos.y-1):
		rM.dS=false

func genMaze():
	mazeInit()

	genPath()

	if isNull(0, 0):
		setCase(0, 0, Room.new())

	genOtherX()

	genOtherY()

	genOther()

	explore()

	clean()
	pass
	