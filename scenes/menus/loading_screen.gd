class_name LoadingScreen
extends Control

@export_file("*.tscn") var scene_select: String
var progress = []

@onready var loading_progress : ProgressBar = %LoadingProgressBar


func _ready() -> void:
	ResourceLoader.load_threaded_request(scene_select)


func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(scene_select, progress)
	if progress[0] >= 1 and status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene := ResourceLoader.load_threaded_get(scene_select)
		get_tree().change_scene_to_packed(scene)
	else:
		loading_progress.value = progress[0] * 100.0


