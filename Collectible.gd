extends Area2D

signal collected()

var rotation_dir := 1.0
var rotation_speed := PI / 4
var building_x
var collected := false
onready var start_phase := randf() * 1000.0

func _ready():
	rotation_dir = 1.0 if randf() < 0.5 else -1.0


func _physics_process(delta):
	rotation += rotation_dir * rotation_speed * delta
	var phase = abs(sin(OS.get_ticks_msec() * 0.001 + start_phase)) * 0.8 + 0.2
	scale = Vector2(phase, phase)
	$sprite.modulate = Color.gray * phase


func _on_Collectible_area_entered(area):
	collect()


func _on_Collectible_body_entered(body):
	collect()


func collect():
	# make sure multiple we don't emit "collected" multiple times
	if collected:
		return
	collected = true
	
	var player = $collection_sounds.get_child(randi() % $collection_sounds.get_child_count())
	player.volume_db = linear2db(0.4)
	player.pitch_scale = 2
	player.play()
	
	$sprite.visible = false
	$particles.emitting = true
	emit_signal('collected')
	yield(player, "finished")
	queue_free()
