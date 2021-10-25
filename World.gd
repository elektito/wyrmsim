extends Node2D

const ROT_SPEED := 1.5

onready var camera := $Wyrm/Segment1/camera

func _ready():
	randomize()
	var x = 0
	for i in range(1000):
		var b = preload("res://Building.tscn").instance()
		b.fill_rate = rand_range(0.04, 0.5)
		b.outline_width = 3
		b.outline_color = Color(0.2, 0.2, 0.2)
		b.window_margin = 5
		var windows = 4 + randi() % 10
		var floors = 5 + randi() % 100
		var width = windows * 10 + 3 * 2 + (windows + 1) * 2
		var height  = floors * 10 + 3 * 2 + (floors + 1) * 2
		var y = 1080 - height
		b.rect_position = Vector2(x, y)
		b.rect_size = Vector2(width, height)
		x += width - b.outline_width
		add_child(b)

func _input(event):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			$Wyrm.pause_mode = Node.PAUSE_MODE_INHERIT
			pause_mode = Node.PAUSE_MODE_INHERIT
			get_tree().paused = false
		else:
			$Wyrm.pause_mode = Node.PAUSE_MODE_STOP
			pause_mode = Node.PAUSE_MODE_PROCESS
			get_tree().paused = true
	if Input.is_action_just_pressed("add_segment"):
		var segments = $Wyrm.get_segments()
		var new_segment = segments[-1].duplicate()
		new_segment.leading_segment = segments[-1].get_path()
		$Wyrm.add_child(new_segment)
	if Input.is_action_just_pressed("remove_segment"):
		var last_segment = $Wyrm.get_segments()[-1]
		$Wyrm.remove_child(last_segment)
	if Input.is_action_just_pressed("zoom_in"):
		camera.zoom -= Vector2(0.1, 0.1)
	if Input.is_action_just_pressed("zoom_out"):
		camera.zoom += Vector2(0.1, 0.1)


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
