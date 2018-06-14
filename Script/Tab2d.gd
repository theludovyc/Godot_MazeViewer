var tab=[]

var width=0
var height=0

func _init(w, h):
	width=w
	height=h
	tab.resize(w*h)

func size():
	return tab.size()

func getCase(x, y):
	return tab[y*width+x]

func isNull(x, y):
	if tab[y*width+x]==null:
		return true
	return false

func setCase(x, y, a):
	tab[y*width+x]=a

func nullCase(x, y):
	tab[y*width+x]=null

func clear():
	tab.clear()
	tab.resize(width*height)