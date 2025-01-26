extends Control
class_name HUD

@onready var debug_label := %DebugLabel
@onready var status_label := %StatusLabel
@onready var menu := %Menu
@onready var crosshair := %Crosshair
@onready var launch_button := %LaunchButton
@onready var debug_node := $Debug
@onready var invert_check := %InvertCheckButton
@onready var sens_spinbox := %SensSpinBox
@onready var setting_root := %Settings
@onready var speedometer_root := %Speedometer
@onready var speedometer_label := %SpeedometerLabel
@onready var rockets_root := %Rockets
@onready var rockets_count_label := %RocketCountLabel
@onready var rocket_progress_bar : ProgressBar = %RocketProgressBar
var rocket_timer : Timer

const MAIN_MENU := "res://scenes/menus/main_menu.tscn"

# func _ready() -> void:
# 	self.hide()

# func on_player_crashed() -> void:
# 	print("crash")
# 	var scn = "res://scenes/menus/main_menu.tscn"
# 	# call_deferred("_change_scene", scn)
# 	call_deferred("func", get_tree().change_scene_to_file(scn))

# func _change_scene(scn):
# 	print("deferred change scene")
# 	get_tree().change_scene_to_file(scn)
	


func _ready() -> void:
	# keeps this script functioning when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu.hide()

	# TODO: add this back on release
	# if not OS.is_debug_build():
	# 	debug_node.hide()

	sens_spinbox.value = GameConfig.mouse_sens
	invert_check.button_pressed = GameConfig.mouse_inverted

	EventsBus.rocket_count_changed.connect(_on_rocket_count_changed)


func _process(_delta: float) -> void:
	update_debug_label()

	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

	# for browser, pause automatically if mouse capture is lost (if user presses escape the browser forces it)
	# TODO: set up full screen toggle as well
	# TODO: figure out some sort of countdown timer for when rapidly pressing the launch button
	# 	    right now, if the launch button is pressed soon after pressing esc, the browser won't let go
	#       of the mouse input. There may be another workaround to avoid this restriction.
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Logger.log("mouse captured", false)
		if not get_tree().paused:
			pause()
	else:
		Logger.log("mouse captured", true)
	
	# update speedometer
	var current_speed :String= Logger.get_speed()
	speedometer_label.text = current_speed

	if is_instance_valid(rocket_timer):
		if rocket_timer.is_stopped():
			rocket_progress_bar.value = 100
		else:
			rocket_progress_bar.value = (rocket_timer.time_left / rocket_timer.wait_time) * 100
	else:
		rocket_timer = get_tree().get_first_node_in_group("rocket_recharge")

func update_debug_label() -> void:
	var result_str:= ""
	for key: String in Logger.debug_dict.keys():
		result_str += key + " (" + type_string(typeof(Logger.debug_dict[key])) + "): " + str(Logger.debug_dict[key]) + "\n"
	
	debug_label.text = result_str

func toggle_pause() -> void:
	if get_tree().paused:
		unpause()
	else:
		pause()

func pause() -> void:
	menu.show()
	setting_root.show()
	crosshair.hide()
	speedometer_root.hide()
	rockets_root.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func unpause() -> void:
	menu.hide()
	setting_root.hide()
	crosshair.show()
	speedometer_root.show()
	rockets_root.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_launch_button_button_up() -> void:
	unpause()

func _on_restart_button_button_up() -> void:
	get_tree().reload_current_scene()
	EventsBus.game_reset.emit()

func _on_exit_to_menu_button_up() -> void:
	self.queue_free()
	get_tree().change_scene_to_file(MAIN_MENU)

func on_player_crashed() -> void:
	Logger.log("player crashed", true)
	status_label.text = "[b][color=red]CRASHED[/color][/b]"
	launch_button.hide()
	pause()

func _on_sens_spin_box_value_changed(value:float) -> void:
	GameConfig.mouse_sens = value

func _on_invert_check_button_toggled(toggled_on:bool) -> void:
	GameConfig.mouse_inverted = toggled_on

func _on_rocket_count_changed(rockets: int) -> void:
	rockets_count_label.text = "[b]" + str(rockets) + " / 2[/b]"
