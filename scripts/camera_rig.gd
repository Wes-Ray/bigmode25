extends Node3D
class_name CameraRig

@export var track_target : Ship
var hud : HUD 

# @export var mouse_sensitivity := 1.  # get from global cfg
@export var max_roll_speed := 3.
@export var roll_accel := 10.
@export var roll_deccel := 20.

const YAW_DAMPEN := 9.0 / 16.0

var current_roll_speed := 0.

var is_free_looking := false
var center_camera_tween : Tween
var return_camera_to_center_time := 0.2

var soundtrack_on := false
@onready var soundtrack_player := %CaveSoundtrack
@onready var deathsound_player := %DeathSound


func _ready() -> void:
	assert(track_target, "there must be a track target assigned before entering scene")
	soundtrack(soundtrack_on)
	

func _process(delta: float) -> void:
	if not is_instance_valid(track_target):
		return
	
	position = track_target.position

	# roll camera
	var roll_input := Input.get_axis("roll_left", "roll_right")
	# scale current_roll_speed smoothly up to max_roll_speed signed the same way as roll_input
	# if no roll input, scale back to 0
	if not is_zero_approx(roll_input):
		current_roll_speed = move_toward(
			current_roll_speed,
			roll_input * max_roll_speed,
			roll_accel * delta
		)
	else:
		current_roll_speed = move_toward(
			current_roll_speed,
			0.,
			roll_deccel * delta
		)

	rotate(basis.z.normalized(), current_roll_speed * delta)

	if Input.is_action_pressed("free_look"):
		is_free_looking = true
	elif Input.is_action_just_released("free_look"):
		is_free_looking = false
		# uncomment to restore camera view to ship view when leaving free look
#		if center_camera_tween:
#			center_camera_tween.kill()
#		center_camera_tween = create_tween()
#		center_camera_tween.set_trans(Tween.TRANS_CUBIC)
#		center_camera_tween.set_ease(Tween.EASE_OUT)
#		center_camera_tween.tween_property(self, "rotation", track_target.rotation, return_camera_to_center_time)
#		center_camera_tween.finished.connect(func(): is_free_looking = false)
	
	Logger.log("is_free_looking", is_free_looking)

func _input(event: InputEvent) -> void:

	if not event is InputEventMouseMotion:
		return
	
	if not is_instance_valid(track_target):
		return
	
	var mouse_movement:Vector2 = event.relative * 0.001 * GameConfig.mouse_sens

	var invert_val := 1.0
	if GameConfig.mouse_inverted:
		invert_val = -1.0
	
	rotate(basis.y.normalized(), -mouse_movement.x * (YAW_DAMPEN))  # yaw
	rotate(basis.x.normalized(), invert_val * mouse_movement.y)  # pitch
	
func soundtrack(do_play : bool) -> void:
	if not do_play:
		return
	soundtrack_player.play()

func on_player_crashed() -> void:
	print("camera saw player crashed")
	deathsound_player.play()
