extends CharacterBody3D
class_name Ship

signal player_crashed
signal player_failed_to_reach_gate

@export var camera_rig : CameraRig
var camera : Camera3D 
var hud : HUD

@export_category("field of view")
@export var max_fov := 130.
@export var mid_fov := 105.
@export var min_fov := 85.
@export var fov_accel := .3

@export_category("foward speed")
@export var max_speed := 100.
@export var min_speed := 60.
@export var boost_immediate := 15.
@export var boost_max_speed := 140.
@export var forward_accel := 8.
@export var boost_accel_mod := 2.
@export var forward_deccel := 3.
@export var brake_deccel_mod := 6.

var speed := min_speed
var boosting := false

@export_category("rotation speed")
@export var pitch_speed := 4.
@export var yaw_speed := 2.
@export var roll_speed := 20.

@export_category("rockets")
@export var max_ammo := 2
@export var ammo_recharge_time := 1.5
@export var cooldown_between_shots := 0.4
@export var projectile_speed := 500.
@export var projectile : PackedScene
var current_launcher := 0
var current_ammo := 0

@onready var launchers : Array[Node3D]
@onready var rocket_recharge_timer : Timer = %RocketRecharge
@onready var rocket_cooldown_timer : Timer = %RocketCooldown
@onready var health_component : HealthComponent = %HealthComponent
@onready var contrail : GPUParticles3D = %Contrail
@onready var bottom_contrail : GPUParticles3D = %BottomContrail

@onready var ship_idle_sfx: AudioStreamPlayer3D = %ShipIdle
@onready var player_dmg_sfx: AudioStreamPlayer3D = %PlayerDamageSound
@onready var chase_rumble_sound :AudioStreamPlayer3D= %ChaseRumbleSound

func _ready() -> void:
	assert(camera_rig, "camera rig must be added before adding to scene")
	#TODO: make a separate function / signal for when player dies to projectiles

	camera = camera_rig.get_node("SpringArm3D").get_node("Camera3D")
	health_component.died.connect(_died)

	current_ammo = max_ammo
	rocket_recharge_timer.wait_time = ammo_recharge_time
	rocket_cooldown_timer.wait_time = cooldown_between_shots
	launchers.append(%LaunchPoint0)
	launchers.append(%LaunchPoint1)

func _process(delta: float) -> void:

	# ORIENTATION LOGIC -----
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

	# SPEED LOGIC -----
	var braking := false

	if Input.is_action_just_pressed("shoot") and not boosting:
		shoot()
	elif Input.is_action_just_pressed("shoot") and boosting:
		hud.shoot_with_no_power()
	if current_ammo < max_ammo and rocket_recharge_timer.is_stopped():
		rocket_recharge_timer.start()

	if Input.is_action_just_pressed("boost"):
		speed += boost_immediate
	if Input.is_action_just_released("boost"):
		speed -= boost_immediate

	if Input.is_action_pressed("throttle_down"):
		braking = true
	if Input.is_action_pressed("boost"):
		boosting = true
	else:
		boosting = false

	if braking:
		speed = move_toward(
			speed,
			min_speed,
			brake_deccel_mod * forward_deccel * delta
		)
		contrail.brake()
		bottom_contrail.brake()
		camera.fov = move_toward(
			camera.fov,
			min_fov,
			fov_accel)

	elif boosting:
		speed = move_toward(
			speed,
			boost_max_speed,
			forward_accel * boost_accel_mod * delta)
		contrail.boost()
		bottom_contrail.boost()
		camera.fov = move_toward(
			camera.fov,
			max_fov,
			fov_accel)


	else:
		if Input.is_action_pressed("throttle_up"):
			speed = move_toward(
				speed,
				max_speed,
				forward_accel * delta
			)
		else: # no speed input
			speed = move_toward(
				speed,
				min_speed,
				forward_deccel * delta
			)
		contrail.throttle()
		bottom_contrail.throttle()
		camera.fov = move_toward(
			camera.fov,
			mid_fov,
			fov_accel)

	# adjust shader speed lines according to speed
	hud.boost_shader.material.set_shader_parameter("line_density", inverse_lerp(min_speed - 20, boost_max_speed, speed) - 0.35)

	Logger.log("speed", speed)
	velocity = forward * speed 
	move_and_slide()
	Logger.log("health", health_component.current_health)

	# adjust ship idle audio based on speed
	ship_idle_sfx.pitch_scale = speed/100.

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
	# print("ship hit: ", _area)
	health_component.take_damage(1)
	player_dmg_sfx.play()

func _died() -> void:
	_death_sound()
	player_crashed.emit()
	queue_free()

func failed_to_reach_gate() -> void:
	player_failed_to_reach_gate.emit()

func _on_rocket_recharge_timeout() -> void:
	current_ammo += 1
	clampi(current_ammo, 0, max_ammo)
	EventsBus.rocket_count_changed.emit(current_ammo)

func _death_sound() -> void:
	await get_tree().create_timer(1).timeout
	$crash.play()


