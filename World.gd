extends Node2D

const ROT_SPEED := 1.5
const BLOCK_SIZE := 5000.0
const BUILDING_MIN_WIDTH := 60.0
const BUILDING_MAX_WIDTH := 300.0

onready var camera := $Wyrm/Segment1/camera

onready var scrh = ProjectSettings.get('display/window/size/height')

var noise = OpenSimplexNoise.new()
var cur_blockx
var block_buildings := {}
var single_stepping := false
var collected_collectibles := []
var visible_collectibles := {}


func _ready():
	randomize()
	noise.seed = randi()
	update_buildings()
	
	yield(get_tree().create_timer(0.75), "timeout")
	$music.play()


func _input(event):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_pressed("add_segment"):
		add_wyrm_segment()
	if Input.is_action_just_pressed("remove_segment"):
		remove_wyrm_segment()
	if Input.is_action_just_pressed("zoom_in"):
		camera.zoom -= Vector2(0.1, 0.1)
	if Input.is_action_just_pressed("zoom_out"):
		camera.zoom += Vector2(0.1, 0.1)
	if Input.is_action_just_pressed("step") and get_tree().paused:
		single_step()
	if Input.is_action_just_pressed("debug"):
		$Wyrm.show_debug = not $Wyrm.show_debug
		for child in $Wyrm.get_children():
			if child.get_filename() == preload("res://Segment.tscn").get_path():
				child.show_debug = not child.show_debug


func _physics_process(delta):
	var dir := Vector2.ZERO
	if Input.is_action_pressed("left"):
		dir += Vector2.LEFT
	if Input.is_action_pressed("right"):
		dir += Vector2.RIGHT
	if Input.is_action_pressed("up"):
		dir += Vector2.UP
	if Input.is_action_pressed("down"):
		dir += Vector2.DOWN
	
	if dir != Vector2.ZERO:
		var desired_rotation1 = fmod(dir.angle() - $Wyrm/Segment1.global_rotation, 2 * PI)
		var desired_rotation2 = desired_rotation1 + 2 * PI if desired_rotation1 < 0.0 else desired_rotation1 - 2 * PI
		var desired_rotation: float
		if abs(desired_rotation1) < abs(desired_rotation2):
			desired_rotation = desired_rotation1
		else:
			desired_rotation = desired_rotation2
		var desired_rotation_speed = desired_rotation / delta
		desired_rotation_speed = clamp(desired_rotation_speed, -ROT_SPEED, ROT_SPEED)
		
		if abs(desired_rotation) < 0.01:
			# snap
			$Wyrm/Segment1.global_rotation = dir.angle()
		else:
			$Wyrm/Segment1.rotate(desired_rotation_speed * delta)


func _process(delta):
	if single_stepping:
		pause()
		single_stepping = false


func _on_building_generation_timer_timeout():
	update_buildings()


func _on_collectible_collected(collectible):
	collected_collectibles.append(collectible.building_x)
	visible_collectibles.erase(collectible.building_x)
	add_wyrm_segment()


func add_wyrm_segment():
	var segments = $Wyrm.get_segments()
	var new_segment = segments[-1].duplicate()
	new_segment.leading_segment = segments[-1].get_path()
	new_segment.position = segments[-1].position - segments[-1].get_velocity() * 0.5
	new_segment.rotation = segments[-1].rotation
	$Wyrm.call_deferred('add_child', new_segment)


func remove_wyrm_segment():
	var last_segment = $Wyrm.get_segments()[-1]
	$Wyrm.remove_child(last_segment)


func unpause():
	$Wyrm.pause_mode = Node.PAUSE_MODE_INHERIT
	pause_mode = Node.PAUSE_MODE_INHERIT
	get_tree().paused = false


func pause():
	$Wyrm.pause_mode = Node.PAUSE_MODE_STOP
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true


func toggle_pause():
	if get_tree().paused:
		unpause()
	else:
		pause()


func single_step():
	unpause()
	single_stepping =  true


func update_buildings():
	var x : float = to_local(camera.global_position).x
	var blockx : float = x - fmod(x, BLOCK_SIZE)
	if blockx == cur_blockx:
		return
	
	var cur_blocks
	var expected_blocks = [blockx - BLOCK_SIZE, blockx, blockx + BLOCK_SIZE]
	
	if cur_blockx == null:
		cur_blocks = []
	else:
		cur_blocks = [cur_blockx - BLOCK_SIZE, cur_blockx, cur_blockx + BLOCK_SIZE]
	
	var removed_blocks = []
	var new_blocks = []
	for bx in cur_blocks:
		if not bx in expected_blocks:
			removed_blocks.append(bx) 
	for bx in expected_blocks:
		if not bx in cur_blocks:
			new_blocks.append(bx)
	for bx in removed_blocks:
		remove_block(bx)
	for bx in new_blocks:
		fill_block(bx)
	
	cur_blockx = blockx


func fill_block(bx: float):
	var x := bx
	var remaining_width := BLOCK_SIZE
	var rng := RandomNumberGenerator.new()
	rng.seed = noise.get_noise_1d(bx)
	while x < bx + BLOCK_SIZE:
		var max_width = min(BUILDING_MAX_WIDTH, remaining_width)
		var width = rng.randf_range(BUILDING_MIN_WIDTH, max_width)
		remaining_width -= width
		if remaining_width > 0 and remaining_width < BUILDING_MIN_WIDTH:
			# we might go a bit above max width, but we won't have next building too narrow (and thus unrenderable)
			width += remaining_width
		var building = generate_building(x, width)
		call_deferred('add_child', building)
		var collectible = generate_collectible(building)
		if collectible != null:
			call_deferred('add_child', collectible)
		x += width
		if bx in block_buildings:
			block_buildings[bx].append(building)
		else:
			block_buildings[bx] = [building]


func remove_block(bx):
	for b in block_buildings[bx]:
		var c = visible_collectibles.get(b.rect_global_position.x)
		if c != null:
			c.queue_free()
		b.queue_free()
	block_buildings.erase(bx)


func generate_building(x: float, width: float):
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(noise.get_noise_1d(x))# * float(1 << 63)
	var seed_value := rng.randi()
	var b = preload("res://Building.tscn").instance()
	b.rng_seed = seed_value
	b.fill_rate = rng.randf_range(0.04, 0.5)
	b.outline_width = 3
	b.outline_color = Color(0.2, 0.2, 0.2)
	b.window_margin = 5
	var floors = 5 + rng.randi() % 100
	var height  = floors * 10 + 3 * 2 + (floors + 1) * 2
	var y = scrh - height
	b.rect_position = Vector2(x, y)
	b.rect_size = Vector2(width, height)
	
	return b


func generate_collectible(building):
	var x: float = building.rect_position.x
	if x in collected_collectibles:
		return null
	if noise.get_noise_1d(x) < 0.2:
		return null
	var c = preload("res://Collectible.tscn").instance()
	c.position.x = x + building.rect_size.x / 2.0
	c.position.y = scrh - building.rect_size.y - 50
	c.building_x = x
	c.connect("collected", self, '_on_collectible_collected', [c])
	visible_collectibles[x] = c
	return c
