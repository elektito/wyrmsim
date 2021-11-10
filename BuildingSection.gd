extends Control

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
var window_rect = null
var rng = RandomNumberGenerator.new()

func _ready():
	init()


func _draw():
	if not initialized:
		return
	
	var dx = Vector2(outline_width / 2, 0)
	var dy = Vector2(0, outline_width / 2)
	var r := Rect2(Vector2.ZERO, rect_size)
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
	draw_line(bottomleft + dx, bottomright - dx, background_color, outline_width)


func init():
	initialized = true
	
	if window_rect != null:
		window_rect.queue_free()
	
	var wr = preload("res://WindowRect.tscn").instance()
	wr.rect_position = Vector2(outline_width / 2 + window_margin, outline_width / 2 + floor_margin)
	wr.rect_size = Vector2(rect_size.x - 2 * outline_width - 2 * window_margin, rect_size.y - 2 * outline_width - 2 * floor_height)
	wr.rng_seed = rng_seed
	wr.fill_rate = fill_rate
	wr.window_color = window_color
	wr.window_width = window_width
	wr.floor_height = floor_height
	wr.floor_margin = floor_margin
	call_deferred('add_child', wr)
	
	# redraw
	update()


func set_rng_seed(value: int):
	rng_seed = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_fill_rate(value: float):
	fill_rate = value
	
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


func set_window_color(value: Color):
	window_color = value
	update()


func set_outline_color(value: Color):
	outline_color = value
	update()


func set_outline_width(value: float):
	outline_width = value
	
	# re-initialize if already initialized
	if initialized:
		init()


func set_background_color(value: Color):
	background_color = value
	update()


func _on_BuildingSection_resized():
	# re-initialize if already initialized
	if initialized:
		init()
