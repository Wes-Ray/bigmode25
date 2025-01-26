extends Control

func _ready() -> void:
	get_tree().paused = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()
