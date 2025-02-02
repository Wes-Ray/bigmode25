extends Control
class_name HUD

var player_ref : Ship
var camera_rig : CameraRig

@onready var debug_label := %DebugLabel
@onready var status_label := %StatusLabel
@onready var menu := %Menu
@onready var crosshair := %Crosshair
@onready var launch_button := %LaunchButton
@onready var debug_node := $Debug
@onready var invert_check := %InvertCheckButton
@onready var sens_spinbox := %SensSpinBox
@onready var setting_root := %Settings
@onready var player_stats_root := %PlayerStats
@onready var speedometer_label := %SpeedometerLabel
@onready var health_label := %HealthLabel
@onready var power_modes_root := %PowerModes
@onready var rockets_count_label := %RocketCountLabel
@onready var rocket_progress_bar : ProgressBar = %RocketProgressBar
@onready var rockets_root := %Rockets
@onready var engines_root := %Engines
@onready var rockets_label := %RocketsLabel
@onready var engines_label := %EnginesLabel
@onready var engine_indicator := %EngineIndicator
@onready var rocket_indicator := %RocketIndicator
@onready var boost_shader := %BoostShader
@onready var height_warning := %CeilingWarning
@onready var chase_timer_root := %ChaseTimer
@onready var chase_timer_label := %ChaseTimerLabel
@onready var tutorial_display_root := %TutorialDisplay
@onready var tutorial_display_label := %TutorialLabel
var tutorial_timer : Timer


var rocket_timer : Timer
var health_change_tween_time := 0.8

var chase_timer : Timer
var chase_timer_total_time := 60.
var chase_timer_active := false

const MAIN_MENU := "res://scenes/menus/main_menu.tscn"

# LightGreen for Default HUD: 1bb500 or Color(0.105, 0.711, 0)
const hud_active_green := Color(0.105, 0.711, 0)
# DarkGreen for Deactivated HUD: Color(0.105, 0.711, 0)
const hud_inactive_green := Color(0, 0.094, 0.031, 0.769)
const hud_active_blue := Color(0.155, 0.614, 0.827)
const hud_active_red := Color(0.9, .1, .1)
	
var current_health: int = 0

func _ready() -> void:
	# keeps this script functioning when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu.hide()

	if not OS.is_debug_build():
		debug_node.hide()

	sens_spinbox.value = GameConfig.mouse_sens
	invert_check.button_pressed = GameConfig.mouse_inverted

	current_health = Logger.get_health()

	EventsBus.rocket_count_changed.connect(_on_rocket_count_changed)

	EventsBus.ceiling_warning_started.connect(_on_ceiling_warning_started)
	EventsBus.ceiling_warning_stopped.connect(_on_ceiling_warning_stopped)


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

	# update health
	var old_health := current_health
	current_health = Logger.get_health()
	if old_health != current_health:
		trigger_health_color_change()

	var fmt_str: String= "[b]%03d[/b]" % (current_health * 6.0)
	health_label.text = fmt_str

	if is_instance_valid(rocket_timer):
		if rocket_timer.is_stopped():
			rocket_progress_bar.value = 100
		else:
			rocket_progress_bar.value = (rocket_timer.time_left / rocket_timer.wait_time) * 100
	else:
		rocket_timer = get_tree().get_first_node_in_group("rocket_recharge")
	
	if is_instance_valid(player_ref):
		if player_ref.boosting:
			engine_indicator.visible = true
			rocket_indicator.visible = false
			engines_label.set("theme_override_colors/default_color", hud_active_green)
			rockets_label.set("theme_override_colors/default_color", hud_inactive_green)
			rockets_count_label.set("theme_override_colors/default_color", hud_inactive_green)
			if player_ref.boosting:
				engines_label.set("theme_override_colors/default_color", hud_active_blue)
			
		else: # guns powered
			engine_indicator.visible = false
			rocket_indicator.visible = true
			engines_label.set("theme_override_colors/default_color", hud_inactive_green)
			rockets_label.set("theme_override_colors/default_color", hud_active_green)
			rockets_count_label.set("theme_override_colors/default_color", hud_active_green)
	
	# if chase timer active
	if chase_timer_active:
		chase_timer_label.text = "[b]%02.2f[/b]" % chase_timer.time_left

	if tutorial_timer:
		Logger.log("tut", tutorial_timer.time_left)

func shoot_with_no_power() -> void:
	var power_label := %PowerLabel
	power_label.set("theme_override_colors/default_color", hud_active_red)
	await get_tree().create_timer(health_change_tween_time).timeout
	power_label.set("theme_override_colors/default_color", hud_active_green)

func activate_chase_timer() -> void: 
	chase_timer_active = true
	chase_timer_label.show()
	chase_timer = Timer.new()
	add_child(chase_timer)
	chase_timer.timeout.connect(chase_timer_finished)
	chase_timer.start(chase_timer_total_time)
	# halfway call out
	await get_tree().create_timer(30.).timeout
	EventsBus.player_objective_complete_trigger.emit(ZoneNames.id.T_MINUS_30)

func deactivate_chase_timer() -> void:
	if chase_timer:
		chase_timer.stop()
		chase_timer.paused = true
	chase_timer_active = false
	chase_timer_label.hide()

func chase_timer_finished() -> void:
	# print("CHASE TIMER FINISHED")
	chase_timer_active = false
	chase_timer.paused = true
	chase_timer_label.hide()
	EventsBus.player_failed_chase.emit()

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
	player_stats_root.hide()
	power_modes_root.hide()
	chase_timer_root.hide()
	tutorial_display_root.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func unpause() -> void:
	menu.hide()
	setting_root.hide()
	crosshair.show()
	player_stats_root.show()
	power_modes_root.show()
	chase_timer_root.show()
	tutorial_display_root.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_launch_button_button_up() -> void:
	unpause()

func trigger_health_color_change() -> void:
	# print("ADDING")
	health_label.set("theme_override_colors/default_color", hud_active_red)
	await get_tree().create_timer(health_change_tween_time).timeout
	health_label.set("theme_override_colors/default_color", hud_active_green)

func _on_restart_button_button_up() -> void:
	get_tree().reload_current_scene()
	EventsBus.game_reset.emit()

func _on_exit_to_menu_button_up() -> void:
	Checkpoint.current_checkpoint = Checkpoint.id.START
	self.queue_free()
	get_tree().change_scene_to_file(MAIN_MENU)

func on_player_crashed() -> void:
	deactivate_chase_timer()
	Logger.log("player crashed", true)
	status_label.text = "[b][color=red]DEFEAT[/color][/b]"
	launch_button.hide()
	EventsBus.game_reset.emit()
	pause()

func on_player_failed_to_reach_gate() -> void:
	deactivate_chase_timer()
	Logger.log("player crashed", true)
	status_label.text = "[b][color=red]DEFEAT[/color][/b]"
	launch_button.hide()
	EventsBus.game_reset.emit()
	pause()

func play_tutorial(text: String) -> void:
	tutorial_display_label.text = "[b]" + text
	tutorial_display_label.show()
	if not tutorial_timer:
		tutorial_timer = Timer.new()
		tutorial_timer.one_shot = true
		add_child(tutorial_timer)
		tutorial_timer.timeout.connect(_tutorial_timeout)
	tutorial_timer.start(4.)

func _tutorial_timeout() -> void:
	# print("tutorial timeout called")
	tutorial_display_label.hide()

func _on_sens_spin_box_value_changed(value:float) -> void:
	GameConfig.mouse_sens = value

func _on_invert_check_button_toggled(toggled_on:bool) -> void:
	GameConfig.mouse_inverted = toggled_on

func _on_rocket_count_changed(rockets: int) -> void:
	rockets_count_label.text = "[b]" + str(rockets) + "/2[/b]"

func _on_ceiling_warning_started() -> void:
	height_warning.show()

func _on_ceiling_warning_stopped() -> void:
	height_warning.hide()
