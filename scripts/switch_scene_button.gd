extends Control
class_name SwitchSceneButton

@export_file("*.tscn") var scene_select: String

func _ready() -> void:
    ResourceLoader.load_threaded_request(scene_select)

func _on_button_up():
    assert(scene_select, "scene must be added in editor, found: '%s'" % scene_select)
    print("changing scene to: ", scene_select)
    # call_deferred("func", get_tree().change_scene_to_file(scene_select))
    get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_select))
