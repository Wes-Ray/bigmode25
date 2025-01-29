class_name ProjectileTurret
extends Node3D

enum firing_type {DIRECT, RANDOM, PREDICT}

@export var fire_mode := firing_type.DIRECT
@export var attack_range := 2000
@export_range(0.5, 10) var fire_rate := 2.0
@export var projectile : PackedScene
@export_range(50, 500) var projectile_speed := 200.0
var cannon_skeleton : Skeleton3D
var cannon_bone_idx : int

@onready var attack_timer : Timer = %AttackTimer
@onready var ship : Ship = get_tree().get_first_node_in_group("ship")
@onready var shooting_point : Marker3D = %ShootingPoint
@onready var turret_top : Node3D = %TurretTop
@onready var direction_finder : Node3D = %DirectionFinder


func _ready() -> void:
	assert(projectile, "projectile scene must be assigned")
	attack_timer.wait_time = fire_rate
	cannon_skeleton = turret_top.find_child("Skeleton3D")
	cannon_bone_idx = cannon_skeleton.find_bone("Bone.001")


func _process(_delta: float) -> void:
	if ship and get_distance(ship.global_position) < attack_range:
		swivel()
		if attack_timer.is_stopped():
			match fire_mode:
				firing_type.DIRECT:
					direct_shoot(generic_shoot())
				firing_type.RANDOM:
					random_shoot(generic_shoot())
				firing_type.PREDICT:
					predict_shoot(generic_shoot())
			attack_timer.start()
	else:
		ship = get_tree().get_first_node_in_group("ship")


func swivel() -> void:
	var dir : Vector3 = ship.global_position - turret_top.global_position
	var dir_horizontal := Vector3(dir.x, 0, dir.z)
	if dir_horizontal.length() < 0.001:
		dir_horizontal = Vector3.FORWARD
	else:
		dir_horizontal = dir_horizontal.normalized()
	var target_horizontal_rot = Basis.looking_at(dir_horizontal, Vector3.UP)
	turret_top.quaternion = turret_top.quaternion.slerp(target_horizontal_rot.get_rotation_quaternion(), 0.5)

	# var pitch_angle := asin(dir.y)
	# var target_pitch_rot = Quaternion(Vector3.RIGHT, pitch_angle)
	# cannon_skeleton.set_bone_pose_rotation(cannon_bone_idx, target_pitch_rot)

func generic_shoot() -> Projectile:
	var proj : Projectile = projectile.instantiate()
	proj.spawner = proj.ENEMY
	get_tree().root.add_child(proj)
	proj.global_position = shooting_point.global_position
	proj.speed = projectile_speed
	return proj


func direct_shoot(proj: Projectile) -> void:
	proj.direction = (ship.global_position - shooting_point.global_position).normalized()


func random_shoot(proj: Projectile) -> void:
	proj.direction = (ship.global_position - shooting_point.global_position)
	var spread = 75  # Adjust this for more/less chaos
	var random_offset = Vector3(
		randf_range(-spread, spread),
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	)
	proj.direction += random_offset
	proj.direction = proj.direction.normalized()


func predict_shoot(proj: Projectile) -> void:
	if is_equal_approx(0, ship.velocity.length()):
		direct_shoot(proj)
		return

	var a := ship.velocity.length_squared() - pow(projectile_speed, 2)
	var b := 2 * (ship.global_position - proj.global_position).dot(ship.velocity)
	var c := pow((ship.global_position - proj.global_position).length(), 2)
	var discriminant := pow(b, 2) - 4*a*c

	if discriminant <= 0:
		direct_shoot(proj)
		return

	if is_equal_approx(a, 0):
		direct_shoot(proj)
		return

	# quadratic formula, we take the lower time so the projectiles don't shoot into space
	var time := (-b - sqrt(discriminant)) / (2 * a)

	if time <= 0:
		time = (-b + sqrt(discriminant)) / (2 * a)
		direct_shoot(proj)
		return

	var proj_velocity = (ship.global_position + time * ship.velocity - proj.global_position) / time
	proj.direction = proj_velocity.normalized()
	proj.speed = proj_velocity.length()


func get_distance(pos: Vector3) -> float:
	return sqrt(pow(pos.x - global_position.x, 2) + pow(pos.y - global_position.y, 2) + pow(pos.z - global_position.z, 2))
