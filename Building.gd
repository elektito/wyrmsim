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
var sections := []
var rng = RandomNumberGenerator.new()

func _ready():
	init()


func init():
	rng.seed = rng_seed
	initialized = true
	
	if sections != []:
		for section in sections:
			section.queue_free()
	var nsections: int
	if rect_size.y < 400:
		nsections = 1
	elif rect_size.y < 500:
		nsections = rng.randi_range(1, 2)
	else:
		nsections = rng.randi_range(1, 3)
	
	var heights := []
	var widths := []
	if nsections == 1:
		heights.append(rect_size.y)
		widths.append(rect_size.x)
	elif nsections == 2:
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
	
	var y = rect_size.y
	for i in range(nsections - 1, -1, -1):
		y -= heights[i]
		var section = preload("res://BuildingSection.tscn").instance()
		var x = rect_size.x / 2.0 - widths[i] / 2.0
		section.rect_position = Vector2(x, y)
		section.rect_size = Vector2(widths[i], heights[i])
		section.rng_seed = rng_seed
		section.fill_rate = fill_rate
		section.window_color = window_color
		section.window_width = window_width
		section.floor_height = floor_height
		section.floor_margin = floor_margin
		section.background_color = background_color
		section.outline_color = outline_color
		call_deferred('add_child', section)
		sections.append(section)
	
	# redraw
	update()


func _on_Building_resized():
	# re-initialize if already initialized
	if initialized:
		init()


func set_outline_width(value: float):
	outline_width = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.outline_width = value


func set_window_width(value: float):
	window_width = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.window_width = value


func set_window_margin(value: float):
	window_margin = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.window_margin = value


func set_floor_height(value: float):
	floor_height = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.floor_height = value


func set_floor_margin(value: float):
	floor_margin = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.floor_margin = value


func set_fill_rate(value: float):
	fill_rate = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.fill_rate = value


func set_outline_color(value: Color):
	outline_color = value
	for s in sections:
		s.outline_color = value
	update()


func set_window_color(value: Color):
	window_color = value
	for s in sections:
		s.window_color = value
	update()


func set_background_color(value: Color):
	background_color = value
	for s in sections:
		s.background_color = value
	update()


func set_rng_seed(value: int):
	rng_seed = value
	
	# re-initialize if already initialized
	if initialized:
		init()
	
	for s in sections:
		s.rng_seed = rng.randi()
