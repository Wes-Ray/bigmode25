extends Control
class_name SwitchSceneButton

# @export var scene_select : PackedScene
@export_file("*.tscn") var scene_select: String

func _on_button_up():
	assert(scene_select, "scene must be added in editor, found: %s" % scene_select)
	print("changing scene to: ", scene_select)
	get_tree().change_scene_to_file(scene_select)
