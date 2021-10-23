extends Polygon2D

export(bool) var show_debug := false
var rects := []

func _ready():
	update_poly()


func _draw():
	var outline_color := Color.black
	var outline_width := 4.0
	var poly = polygon
	for i in range(1 , poly.size()):
		draw_line(poly[i-1] , poly[i], outline_color, outline_width, true)
	draw_line(poly[poly.size() - 1] , poly[0], outline_color, outline_width, true)
	
	if show_debug:
		# draw debug rects
		for r in rects:
			for j in len(r):
				r[j] = to_local(r[j])
			draw_line(r[0], r[1], Color.red, 2, true)
			draw_line(r[1], r[2], Color.red, 2, true)
			draw_line(r[2], r[3], Color.red, 2, true)
			draw_line(r[3], r[0], Color.red, 2, true)


func update_poly():
	# construct a rectangle for each segment (each rectangle is an array of four points)
	rects = []
	for child in get_segments():
		var width = child.get_node('rect').rect_size.x
		var height = child.get_node('rect').rect_size.y
		var growth = 1.8
		var r = [
			child.to_global(Vector2(-width / 2, -height / 2) * growth), # top-left
			child.to_global(Vector2(width / 2, -height / 2) * growth),  # top-right
			child.to_global(Vector2(width / 2, height / 2) * growth),   # bottom-right
			child.to_global(Vector2(-width / 2, height / 2) * growth),  # bottom-left
		]
		rects.append(r)
	
	# now construct the polygon based on the rectangles
	
	var points := []
	
	# the forward tip of the head
	points.append(to_local(rects[0][2] + (rects[0][2] - rects[0][3])))
	
	for r in rects:
		points.append(to_local((r[2] + r[3]) / 2))
	
	# the end of the tail
	points.append(to_local(rects[-1][3] + 2*(rects[-1][3] - rects[-1][2])))
	
	for i in range(len(rects) - 1, -1, -1):
		points.append(to_local((rects[i][0] + rects[i][1]) / 2))
	
	# top point of the head
	points.append(to_local(rects[0][1] + (rects[0][1] - rects[0][2]) * 0.3))
	
	polygon = PoolVector2Array(points)


func get_segments():
	var segments := []
	for child in get_children():
		if child.get_filename() == preload("res://Segment.tscn").get_path():
			segments.append(child)
	return segments


func _physics_process(delta):
	update_poly()
