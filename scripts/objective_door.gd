extends Node3D
class_name ObjectiveDoor

@export var anim_speed := 1.0

func close_objective_door() -> void:
	$AnimationPlayer.speed_scale = anim_speed
	$AnimationPlayer.play("shut_door")
