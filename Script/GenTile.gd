static func genTile(tile, parent, x, y):
	var node=tile.instance()
	parent.add_child(node)
	node.position=Vector2(x, y)
	return node

static func genTileRot(tile, parent, x, y, rot):
	var node=tile.instance()
	parent.add_child(node)
	node.position=Vector2(x, y)
	node.rotate(rot)
	return node
