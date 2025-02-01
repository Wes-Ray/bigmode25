extends Node3D
class_name ObjectiveDoor

@export var anim_speed := 1.0

func _process(_delta):
	if Input.is_action_just_pressed("debug4"):
		close_objective_door()

func close_objective_door() -> void:
	print("closing obj door")
	$AnimationPlayer.speed_scale = anim_speed
	$AnimationPlayer.play("shut_door")
	