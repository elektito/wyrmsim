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
var window_rect = null
var rng = RandomNumberGenerator.new()

func _ready():
	init()


func init():
	rng.seed = rng_seed
	initialized = true
	
	if window_rect != null:
		window_rect.queue_free()
	window_rect = preload("res://WindowRect.tscn").instance()
	window_rect.rect_position = Vector2(outline_width / 2 + window_margin, outline_width / 2 + floor_margin)
	window_rect.rect_size = rect_size - Vector2(2 * outline_width + 2 * window_margin, 2 * outline_width + 2 * floor_height)
	window_rect.rng_seed = rng_seed
	window_rect.fill_rate = fill_rate
	window_rect.window_color = window_color
	window_rect.window_width = window_width
	window_rect.floor_height = floor_height
	window_rect.floor_margin = floor_margin
	call_deferred('add_child', window_rect)
	
	# redraw
	update()


func _draw():
	if not initialized:
		return
	
	var rect = Rect2(outline_width / 2, outline_width / 2, rect_size.x - outline_width, rect_size.y - outline_width)
	draw_rect(rect, background_color, true)
	draw_rect(rect, outline_color, false, outline_width, antialiased)
	
	rect.position += Vector2(outline_width / 2, outline_width / 2)
	rect.size -= Vector2(outline_width, outline_width)



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
	
	if window_rect:
		window_rect.window_color = value
		window_rect.update()


func set_background_color(value: Color):
	background_color = value
	update()


func set_rng_seed(value: int):
	rng_seed = value
	
	# re-initialize if already initialized
	if initialized:
		init()
