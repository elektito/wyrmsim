extends Area2D

signal collected()

var rotation_dir := 1.0
var rotation_speed := PI / 4

func _ready():
	rotation_dir = 1.0 if randf() < 0.5 else -1.0


func _physics_process(delta):
	rotation += rotation_dir * rotation_speed * delta


func _on_Collectible_area_entered(area):
	emit_signal('collected')


func _on_Collectible_body_entered(body):
	emit_signal('collected')
