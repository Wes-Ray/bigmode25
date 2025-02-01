class_name SmallShip
extends PathFollow3D

@export var explosion_time := 15.0
var starting_position : Vector3
var shooting_time : float

@onready var parent_path : Path3D = get_parent()
@onready var laser_scene : PackedScene = preload("res://assets/props/sky_props/ship_laser_red.tscn")
@onready var shooting_points := [
	%ShootingPoint1,
	%ShootingPoint2
]
@onready var explosion : SkyExplosion = %SkyExplosion
@onready var explosion_timer : Timer = %ExplosionTimer
@onready var shooting_timer : Timer = %ShootingTimer
@onready var shoot_towards : Node3D = %ShootTowards


func _ready() -> void:
	starting_position = global_position
	explosion_timer.wait_time = explosion_time
	shooting_time = randf_range(1.0, 5.0)
	shooting_timer.start(shooting_time)


func shoot(ind: int) -> void:
	var laser : Node3D = laser_scene.instantiate()
	get_tree().root.add_child(laser)
	laser.global_position = shooting_points[ind].global_position
	laser.direction = global_position.direction_to(shoot_towards.global_position)



func _on_shooting_timer_timeout() -> void:
	shooting_timer.stop()

	shoot(1)
	shoot(0)
	await get_tree().create_timer(0.2).timeout
	shoot(1)
	shoot(0)
	await get_tree().create_timer(0.2).timeout
	shoot(1)
	shoot(0)

	shooting_time = randf_range(1.0, 3.0)
	shooting_timer.wait_time = shooting_time
	shooting_timer.start()


func _on_explosion_timer_timeout() -> void:
	# Keep the explsion in place
	remove_child(explosion)
	get_tree().root.add_child(explosion)
	explosion.explode()
	global_position = starting_position

	# Add the explosion back to own position 
	await get_tree().create_timer(2).timeout
	get_tree().root.remove_child(explosion)
	add_child(explosion)
	explosion.position = Vector3.ZERO

	parent_path.progress = 0
