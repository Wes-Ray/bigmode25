extends Control

@onready var sensitivity := %SensSpinBox
@onready var inverted := %InvertCheckButton
@onready var fullscreen := %FullscreenButton


func _ready() -> void:
	inverted.button_pressed = GameConfig.mouse_inverted
	sensitivity.value = GameConfig.mouse_sens
	fullscreen.button_pressed = GameConfig.full_screen
	get_tree().paused = false

func _on_sens_spin_box_value_changed(value:float) -> void:
	GameConfig.mouse_sens = value

func _on_invert_check_button_toggled(toggled_on:bool) -> void:
	GameConfig.mouse_inverted = toggled_on

func _on_fullscreen_button_toggled(toggled_on:bool) -> void:
	GameConfig.full_screen = toggled_on
	update_screen_setting()

func update_screen_setting() -> void:
	if GameConfig.full_screen:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: # not full screen
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
