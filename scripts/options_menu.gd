extends Control

@export var main_menu := "res://scenes/menus/main_menu.tscn"

@onready var sensitivity := %SensSpinBox
@onready var inverted := %InvertCheckButton


func _ready() -> void:
	inverted.button_pressed = GameConfig.mouse_inverted
	sensitivity.value = GameConfig.mouse_sens


func _on_sens_spin_box_value_changed(value:float) -> void:
	GameConfig.mouse_sens = value


func _on_invert_check_button_toggled(toggled_on:bool) -> void:
	GameConfig.mouse_inverted = toggled_on


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu)
