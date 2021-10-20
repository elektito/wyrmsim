extends Node2D

const ROT_SPEED := 1.5

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
