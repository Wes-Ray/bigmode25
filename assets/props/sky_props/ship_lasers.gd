class_name ShipLasers
extends Node3D

var speed := 1500
var direction := Vector3.FORWARD
var look_here := Vector3.FORWARD


func _ready() -> void:
	if is_instance_valid(look_here):
		look_at(look_here)


func _process(delta: float) -> void:
	global_position += speed * delta * direction


func _on_timer_timeout() -> void:
	queue_free()
