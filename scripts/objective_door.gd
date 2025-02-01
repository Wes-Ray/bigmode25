extends Node3D

func _process(_delta):
	if Input.is_action_just_pressed("debug4"):
		close_objective_door()

func close_objective_door() -> void:
	print("closing obj door")
	$AnimationPlayer.play("shut_door")