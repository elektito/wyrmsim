extends Control
tool

export(int) var rng_seed := 0 setget set_rng_seed
export(float, 0.0, 1.0, 0.01) var fill_rate := 0.2 setget set_fill_rate
export(float) var floor_height := 10.0 setget set_floor_height
export(float) var floor_margin := 2.0 setget set_floor_margin
export(float) var window_width := 10.0 setget set_window_width
export(float) var window_margin := 2.0 setget set_window_margin
export(Color) var window_color := Color.yellow setget set_window_color

var rng := RandomNumberGenerator.new()
var windows_per_floor: int
var floors: int
var windows := []
var darkness := []

var initialized := false


func _ready():
	if not initialized:
		init()


func _draw():
	if not initialized:
		return
	
	var first_window_x = (rect_size.x - windows_per_floor * window_width - (windows_per_floor - 1) * window_margin) / 2.0
	var first_window_y = (rect_size.y - floors * floor_height - (floors - 1) * floor_margin) / 2.0
	
	for f in range(floors):
		for w in range(windows_per_floor):
			if windows[f][w]:
				var pos = Vector2(first_window_x + w * (window_width + window_margin), first_window_y + f * (floor_height + floor_margin))
				var r = Rect2(pos, Vector2(window_width, floor_height))
				draw_rect(r, window_color.darkened(darkness[f][w]), true)


func init():
	floors = int(floor((rect_size.y - 1 * floor_margin) / (floor_height + floor_margin)))
	windows_per_floor = int(floor((rect_size.x - 1 * window_margin) / (window_width + window_margin)))
	
	windows = []
	darkness = []
	for i in range(floors):
		windows.append([])
		darkness.append([])
		for j in range(windows_per_floor):
			windows[i].append(false)
			darkness[i].append(rng.randf_range(0.0, 1.0))
	
	# now turn on some of the lights
	var total_lit := 0
	for f in range(floors):
		var cur_fill_rate = float(total_lit) / (windows_per_floor * (f + 1))
		var style = rng.randf()
		if cur_fill_rate < fill_rate:
			if style < 0.1:
				# one whole lit floor
				for i in range(windows_per_floor):
					windows[f][i] = true
				total_lit += windows_per_floor
			elif style < 0.2:
				# one string of lit windows
				var length = rng.randi() % windows_per_floor
				var start = rng.randi() % (windows_per_floor - length)
				for i in range(length):
					windows[f][start + i] = true
				total_lit += length
			elif style < 0.5:
				var filled := 0
				for x in range(2):
					var length = rng.randi() % (windows_per_floor - filled)
					var start = rng.randi() % (windows_per_floor - filled - length)
					for i in range(length):
						windows[f][filled + start + i] = true
					filled += length
					total_lit += length
			else:
				# some individual lit windows
				for w in range(windows_per_floor):
					if rng.randf() < fill_rate:
						windows[f][w] = true
						total_lit += 1
	
	# sometimes empty out columns of windows to suggest vertical windowless areas
	if rng.randf() < 0.5:
		var columns : int = rng.randi() % 2 + 1
		for i in range(columns):
			var w = rng.randi() % windows_per_floor
			for f in range(floors):
				windows[f][w] = false
	
	# empty out one or more rows at the bottom
	var bottom_rows = 1
	if floors > 7:
		bottom_rows = rng.randi() % 4 + 1
	for i in range(bottom_rows):
		for w in windows_per_floor:
			windows[floors - 1 - i][w] = false
	
	# randomly turn off some whole floors
	for i in range(0, rng.randi_range(0, fill_rate * floors)):
		var f1 = rng.randi() % floors
		var f2 = f1 + 1 + rng.randi_range(0, log(floors))
		if f2 >= floors:
			f2 = floors - 1
		for f in range(f1, f2):
			for w in windows_per_floor:
				windows[f][w] = false
	
	initialized = true
	
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


func _on_WindowRect_resized():
	# re-initialize if already initialized
	if initialized:
		init()
