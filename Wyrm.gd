extends Polygon2D

func _ready():
	update_poly()


func update_poly():
	var rects := []
	for child in get_children():
		var width = child.get_node('rect').rect_size.x
		var height = child.get_node('rect').rect_size.y
		var r = [
			child.to_global(Vector2(-width / 2, -height / 2)),
			child.to_global(Vector2(width / 2, -height / 2)),
			child.to_global(Vector2(width / 2, height / 2)),
			child.to_global(Vector2(-width / 2, height / 2)),
		]
		rects.append(r)
	
	var points := []
	
	# the forward tip of the head
	points.append(to_local(rects[0][2] + (rects[0][2] - rects[0][3])))
	
	for r in rects:
		points.append(to_local(r[2]))
		points.append(to_local(r[3]))
	
	# the end of the tail
	points.append(to_local(rects[-1][3] + 2*(rects[-1][3] - rects[-1][2])))
	
	for i in range(len(rects) - 1, -1, -1):
		points.append(to_local(rects[i][0]))
		points.append(to_local(rects[i][1]))
	
	polygon = PoolVector2Array(points)


func _physics_process(delta):
	update_poly()
