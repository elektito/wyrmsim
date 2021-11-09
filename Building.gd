tool
extends Control

export(bool) var antialiased := false
export(Color) var outline_color := Color.white setget set_outline_color
export(float) var outline_width := 3.0 setget set_outline_width
export(Color) var background_color := Color.black setget set_background_color

export(Color) var window_color := Color.yellow setget set_window_color
export(float) var window_width := 10.0 setget set_window_width
export(float) var window_margin := 2.0 setget set_window_margin
export(float) var floor_height := 10.0 setget set_floor_height
export(float) var floor_margin := 2.0 setget set_floor_margin

export(int) var rng_seed := 0 setget set_rng_seed

export(float, 0.0, 1.0, 0.01) var fill_rate := 0.2 setget set_fill_rate

var initialized := false
var window_rects := []
var section_rects := []
var rng = RandomNumberGenerator.new()

func _ready():
	init()


func init():
	rng.seed = rng_seed
	initialized = true
	
	if window_rects != []:
		for wr in window_rects:
			wr.queue_free()
	var sections: int
	if rect_size.y < 400:
		sections = 1
	elif rect_size.y < 500:
		sections = rng.randi_range(1, 2)
	else:
		sections = rng.randi_range(1, 3)
	
	var heights := []
	var widths := []
	if sections == 1:
		heights.append(rect_size.y)
		widths.append(rect_size.x)
	elif sections == 2:
		var h1 = rect_size.y / rng.randf_range(3, 5)
		var h2 = rect_size.y - h1
		heights.append_array([h1, h2])
		
		var w2 = rect_size.x
		var w1 = rect_size.x / rng.randf_range(1.5, 4.0)
		widths.append_array([w1, w2])
	else:
		var h1 = rect_size.y / rng.randf_range(1.5, 4.0)
		var h2 = (rect_size.y - h1) / rng.randf_range(1.5, 4.0)
		var h3 = rect_size.y - h1 - h2
		heights.append_array([h1, h2, h3])
		
		var w3 = rect_size.x
		var w2 = rect_size.x / rng.randf_range(1.5, 4.0)
		var w1 = w2 / rng.randf_range(1.5, 4.0)
		widths.append_array([w1, w2, w3])
	
	var y = 0.0
	for i in range(sections):
		var wr = preload("res://WindowRect.tscn").instance()
		var x = rect_size.x / 2.0 - widths[i] / 2.0
		wr.rect_position = Vector2(x + outline_width / 2 + window_margin, y + outline_width / 2 + floor_margin)
		wr.rect_size = Vector2(widths[i] - 2 * outline_width - 2 * window_margin, heights[i] - 2 * outline_width - 2 * floor_height)
		wr.rng_seed = rng_seed
		wr.fill_rate = fill_rate
		wr.window_color = window_color
		wr.window_width = window_width
		wr.floor_height = floor_height
		wr.floor_margin = floor_margin
		call_deferred('add_child', wr)
		section_rects.append(Rect2(x, y, widths[i], heights[i]))
		y += heights[i]
	
	# redraw
	update()


func _draw():
	if not initialized:
		return
	
	for i in range(len(section_rects) - 1, -1, -1):
		var dx = Vector2(outline_width / 2, 0)
		var dy = Vector2(0, outline_width / 2)
		var r: Rect2 = section_rects[i]
		r.position += dx + dy
		r.size -= dx - dy
		draw_rect(r, background_color, true)
		
		var topleft = r.position
		var topright = r.position + Vector2(r.size.x, 0)
		var bottomleft = r.position + Vector2(0, r.size.y)
		var bottomright = r.position + r.size
		draw_line(topleft, bottomleft, outline_color, outline_width)
		draw_line(topleft - dx, topright + dx, outline_color, outline_width)
		draw_line(topright, bottomright, outline_color, outline_width)
		if i == len(section_rects) - 1:
			draw_line(bottomleft + dx, bottomright - dx, Color.black, outline_width)


func _on_Building_resized():
	# re-initialize if already initialized
	if initialized:
		init()


func set_outline_width(value: float):
	outline_width = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_window_width(value: float):
	window_width = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_window_margin(value: float):
	window_margin = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_floor_height(value: float):
	floor_height = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_floor_margin(value: float):
	floor_margin = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_fill_rate(value: float):
	fill_rate = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_outline_color(value: Color):
	outline_color = value
	update()


func set_window_color(value: Color):
	window_color = value
	update()
	
	for wr in window_rects:
		wr.window_color = value
		wr.update()


func set_background_color(value: Color):
	background_color = value
	update()


func set_rng_seed(value: int):
	rng_seed = value
	
	# re-initialize if already initialized
	if initialized:
		init()
