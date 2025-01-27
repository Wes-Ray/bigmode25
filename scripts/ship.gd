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

@export_category("rockets")
@export var max_ammo := 2
@export var ammo_recharge_time := 1.5
@export var cooldown_between_shots := 0.4
@export var projectile_speed := 250
@export var projectile : PackedScene
var current_launcher := 0
var current_ammo := 0

@onready var launchers : Array[Node3D]
@onready var rocket_recharge_timer : Timer = %RocketRecharge
@onready var rocket_cooldown_timer : Timer = %RocketCooldown
@onready var health_component : HealthComponent = %HealthComponent

func _ready() -> void:
	assert(camera_rig, "camera rig must be added before adding to scene")
	#TODO: make a separate function / signal for when player dies to projectiles

	health_component.died.connect(_died)

	current_ammo = max_ammo
	rocket_recharge_timer.wait_time = ammo_recharge_time
	rocket_cooldown_timer.wait_time = cooldown_between_shots
	launchers.append(%LaunchPoint0)
	launchers.append(%LaunchPoint1)


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

	if Input.is_action_just_pressed("shoot"):
		shoot()
	if current_ammo < max_ammo and rocket_recharge_timer.is_stopped():
		rocket_recharge_timer.start()

	Logger.log("speed", speed)
	velocity = forward * speed
	move_and_slide()
	Logger.log("health", health_component.current_health)

func shoot():
	if current_ammo > 0 and rocket_cooldown_timer.is_stopped():
		var proj : Projectile = projectile.instantiate()
		proj.direction = camera_rig.basis.z
		proj.speed = projectile_speed
		proj.spawner = proj.PLAYER
		get_tree().root.add_child(proj)
		proj.global_position = launchers[current_launcher].global_position
		current_launcher = 1 if current_launcher == 0 else 0
		current_ammo -= 1
		rocket_cooldown_timer.start()
		EventsBus.rocket_count_changed.emit(current_ammo)

func _on_collision_area_body_entered(_body: Node3D) -> void:
	# TODO: add explodies
	# print("collied: ", _body)
	_death_sound()
	player_crashed.emit()
	queue_free()

func _on_collision_area_area_entered(_area: Area3D) -> void:
	health_component.take_damage(1)


func _died() -> void:
	_death_sound()
	player_crashed.emit()
	queue_free()


func _on_rocket_recharge_timeout() -> void:
	current_ammo += 1
	clampi(current_ammo, 0, max_ammo)
	EventsBus.rocket_count_changed.emit(current_ammo)

func _death_sound() -> void:
	await get_tree().create_timer(1).timeout
	$crash.play()
