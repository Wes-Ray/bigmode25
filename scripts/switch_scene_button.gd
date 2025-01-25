extends Control
class_name SwitchSceneButton

@export var scene_select : PackedScene

func _on_button_up():
	assert(scene_select, "scene must be added in editor")
	get_tree().change_scene_to_packed(scene_select)
