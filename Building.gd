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

export(float, 0.0, 1.0, 0.01) var fill_rate := 0.2 setget set_fill_rate

var windows_per_floor : int
var floors : int
var windows := []

func _ready():
	init()


func init():
	floors = int(floor((rect_size.y - 2 * outline_width - 1 * floor_margin) / (floor_height + floor_margin)))
	windows_per_floor = int(floor((rect_size.x - 2 * outline_width - 1 * window_margin) / (window_width + window_margin)))
	
	windows = []
	for i in range(floors):
		windows.append([])
		for j in range(windows_per_floor):
			windows[i].append(false)
	
	# now turn on some of the lights
	var total_lit := 0
	for f in range(floors):
		var cur_fill_rate = float(total_lit) / (windows_per_floor * (f + 1))
		var style = randf()
		if cur_fill_rate < fill_rate:
			if style < 0.1:
				# one whole lit floor
				for i in range(windows_per_floor):
					windows[f][i] = true
				total_lit += windows_per_floor
			elif style < 0.2:
				# one string of lit windows
				var length = randi() % windows_per_floor
				var start = randi() % (windows_per_floor - length)
				for i in range(length):
					windows[f][start + i] = true
				total_lit += length
			elif style < 0.5:
				var filled := 0
				for x in range(2):
					var length = randi() % (windows_per_floor - filled)
					var start = randi() % (windows_per_floor - filled - length)
					for i in range(length):
						windows[f][filled + start + i] = true
					filled += length
					total_lit += length
			else:
				# some individual lit windows
				for w in range(windows_per_floor):
					if randf() < fill_rate:
						windows[f][w] = true
						total_lit += 1
	
	# sometimes empty out columns of windows to suggest vertical windowless areas
	if randf() < 0.5:
		var columns := randi() % 2 + 1
		for i in range(columns):
			var w = randi() % windows_per_floor
			for f in range(floors):
				windows[f][w] = false
	
	# empty out one or more rows at the bottom
	var bottom_rows = 1
	if floors > 7:
		bottom_rows = randi() % 4 + 1
	for i in range(bottom_rows):
		for w in windows_per_floor:
			windows[floors - 1 - i][w] = false
	
	# redraw
	update()


func _draw():
	var rect = Rect2(outline_width / 2, outline_width / 2, rect_size.x - outline_width, rect_size.y - outline_width)
	draw_rect(rect, background_color, true)
	draw_rect(rect, outline_color, false, outline_width, antialiased)
	for f in range(floors):
		var darkness = rand_range(0.0, 1.0)
		for w in range(windows_per_floor):
			if windows[f][w]:
				var pos = Vector2(outline_width + window_margin + w * (window_width + window_margin), outline_width + floor_margin + f * (floor_height + floor_margin))
				var r = Rect2(pos, Vector2(window_width, floor_height))
				draw_rect(r, window_color.darkened(darkness), true)


func _on_Building_resized():
	init()


func set_outline_width(value: float):
	outline_width = value
	init()


func set_window_width(value: float):
	window_width = value
	init()


func set_window_margin(value: float):
	window_margin = value
	init()


func set_floor_height(value: float):
	floor_height = value
	init()


func set_floor_margin(value: float):
	floor_margin = value
	init()


func set_fill_rate(value: float):
	fill_rate = value
	init()


func set_outline_color(value: Color):
	outline_color = value
	update()


func set_window_color(value: Color):
	window_color = value
	update()


func set_background_color(value: Color):
	background_color = value
	update()
