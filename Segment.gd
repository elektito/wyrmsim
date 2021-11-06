extends KinematicBody2D

const MAX_ROTATION_SPEED := PI
const SEGMENT_DISTANCE := 20.0

export(NodePath) var leading_segment
export(float) var speed := 500.0
export(bool) var show_debug = false setget set_show_debug
export(float) var max_acceleration := 100.0
export(float) var min_speed := 300.0
export(float) var max_speed := 700

var leading_node : Node2D = null
var original_distance := 0.0
var acceleration := 0.0

func _ready():
	if leading_segment:
		leading_node = get_node(leading_segment)
		original_distance = (leading_node.global_position - global_position).length()
		$target.visible = show_debug
		$target_line.visible = show_debug
		position.y = leading_node.position.y
		position.x = leading_node.position.x - 60
	else:
		$target.visible = false
		$target_line.visible = false
		
	$rect.visible = show_debug


func _physics_process(delta):
	if leading_node:
		follower_movement(delta)
	else:
		leader_movement(delta)


func leader_movement(delta):
	var dir = Vector2.RIGHT.rotated(rotation)
	
	if abs(dir.x) < 0.01 or abs(dir.y) < 0.01:
		acceleration = -max_acceleration
	else:
		# you get max acceleration when moving at a multiple of 45 degrees
		acceleration = fposmod(dir.angle(), PI / 4) / (PI / 4) * max_acceleration
	
	speed += acceleration * delta
	speed = clamp(speed, min_speed, max_speed)
	
	var velocity = speed * dir
	move_and_slide(velocity)


func follower_movement(delta):
	var target_pos : Vector2 = leading_node.global_position - leading_node.get_velocity().normalized() * SEGMENT_DISTANCE
	var linear_velocity = (target_pos - global_position) / delta
	linear_velocity = linear_velocity.clamped(leading_node.speed * 1.0)
	
	var target_rot : float = (leading_node.global_position - global_position).angle()
	var desired_rotation1 = fmod(target_rot - global_rotation, 2 * PI)
	var desired_rotation2 = desired_rotation1 + 2 * PI if desired_rotation1 < 0.0 else desired_rotation1 - 2 * PI
	var desired_rotation: float
	if abs(desired_rotation1) < abs(desired_rotation2):
		desired_rotation = desired_rotation1
	else:
		desired_rotation = desired_rotation2
	var rotation_speed = desired_rotation / delta

	if abs(rotation_speed) > MAX_ROTATION_SPEED:
		rotation_speed = sign(rotation_speed) * MAX_ROTATION_SPEED
	
	speed = linear_velocity.length()
	
	move_and_slide(linear_velocity)
	rotate(rotation_speed * delta)
	
	$target.global_position = target_pos
	$target_line.points[0] = $target_line.to_local($target.global_position)
	$target_line.points[1] = $target_line.to_local(global_position)


func get_velocity() -> Vector2:
	var dir = Vector2.RIGHT.rotated(global_rotation)
	return speed * dir


func set_show_debug(value: bool):
	show_debug = value
	$target.visible = show_debug
	$target_line.visible = show_debug
	$rect.visible = show_debug
