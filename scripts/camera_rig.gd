extends Node3D
class_name CameraRig

@export var track_target : Ship
# @export var mouse_sensitivity := 1.  # get from global cfg
@export var max_roll_speed := 3.
@export var roll_accel := 10.
@export var roll_deccel := 20.
var current_roll_speed := 0.

func _ready() -> void:
	assert(track_target, "there must be a track target assigned before entering scene")

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

func _input(event: InputEvent) -> void:

	if not event is InputEventMouseMotion:
		return
	
	if not is_instance_valid(track_target):
		return
	
	var mouse_movement:Vector2 = event.relative * 0.001 * GameConfig.mouse_sens

	var invert_val := 1.0
	if GameConfig.mouse_inverted:
		invert_val = -1.0
	
	rotate(basis.y.normalized(), -mouse_movement.x * (9.0/16.0))  # yaw
	rotate(basis.x.normalized(), invert_val * mouse_movement.y)  # pitch
