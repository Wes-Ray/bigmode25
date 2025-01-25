extends CharacterBody3D
class_name Ship

signal player_crashed

@export var camera_rig : CameraRig

@export_category("foward speed")
@export var max_speed := 80.
@export var min_speed := 50.
@export var forward_accel := 10.
@export var boost_accel_mod := 3.
@export var forward_deccel := 14.
@export var brake_deccel_mod := 2.

var speed := min_speed

@export_category("rotation speed")
@export var pitch_speed := 3.5
@export var yaw_speed := 1.
@export var roll_speed := 20.

@onready var health_component : HealthComponent = %HealthComponent

func _ready() -> void:
	assert(camera_rig, "camera rig must be added before adding to scene")
	#TODO: make a separate function / signal for when player dies to projectiles
	health_component.died.connect(_died)

func _process(delta: float) -> void:
	var forward := basis.z

	if not camera_rig.is_free_looking:
		var cam_tf := camera_rig.global_transform
		var desired_forward := cam_tf.basis.z
		var desired_up := cam_tf.basis.y

		var target_basis := Basis()
		target_basis.z = desired_forward.normalized()
		target_basis.y = desired_up.normalized()
		target_basis.x = target_basis.y.cross(target_basis.z).normalized()
		target_basis = target_basis.orthonormalized()

		var current_to_target := basis.inverse() * target_basis
		var rotation_diff := current_to_target.get_euler()

		# dampen the roll speed on large pitch / yaw changes to stabilize their calculations (ship spaz fix)
		var damp_roll_speed := roll_speed
		if abs(rotation_diff.x) > 1.0 or abs(rotation_diff.y) > 1.0:
			damp_roll_speed = roll_speed / 5.

		# scaling so large camera rotation difference don't speed up rotations
		var angular_velocity = Vector3(
			sign(rotation_diff.x) * min(abs(rotation_diff.x), 1.0) * pitch_speed,
			sign(rotation_diff.y) * min(abs(rotation_diff.y), 1.0) * yaw_speed,
			sign(rotation_diff.z) * min(abs(rotation_diff.z), 1.0) * damp_roll_speed
		)

		basis = basis.rotated(basis.x, angular_velocity.x * delta)
		basis = basis.rotated(basis.y, angular_velocity.y * delta)
		basis = basis.rotated(basis.z, angular_velocity.z * delta)

		basis = basis.orthonormalized()

		
	if Input.is_action_pressed("throttle_up"):
		var boosting := false
		if Input.is_action_pressed("boost"):
			boosting = true
		speed = move_toward(
			speed,
			max_speed,
			forward_accel * (boost_accel_mod if boosting else 1.) * delta
		)
	else:
		var braking := false
		if Input.is_action_pressed("throttle_down"):
			braking = true
		speed = move_toward(
			speed,
			min_speed,
			forward_deccel * (brake_deccel_mod if braking else 1.) * delta
		)

	Logger.log("speed", speed)
	velocity = forward * speed
	move_and_slide()
	Logger.log("health", health_component.current_health)

func _on_collision_area_body_entered(_body: Node3D) -> void:
	# TODO: add explodies
	# print("collied: ", _body)
	player_crashed.emit()
	queue_free()

func _on_collision_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("projectile_hitbox"):
		health_component.take_damage(1)


func _died() -> void:
	player_crashed.emit()
	queue_free()
