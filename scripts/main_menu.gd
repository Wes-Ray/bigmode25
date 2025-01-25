extends Control

@onready var options_menu := "res://scenes/menus/options_menu.tscn"
@onready var level := "res://scenes/levels/level01.tscn"
	

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file(options_menu)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(level)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
