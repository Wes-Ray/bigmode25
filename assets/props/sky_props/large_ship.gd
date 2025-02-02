class_name LargeShip
extends Node3D

var explosion_time : float
@onready var lasers := [
	preload("res://assets/props/sky_props/ship_laser_blue.tscn"),
	preload("res://assets/props/sky_props/ship_laser_red.tscn"),
	preload("res://assets/props/sky_props/ship_laser_green.tscn"),
]
@onready var explosion_points := [
	%SkyExplosion,
	%SkyExplosion2,
	%SkyExplosion3,
]
@onready var shoot_towards := [
	%ShootTowards1,
	%ShootTowards2,
	%ShootTowards3,
	%ShootTowards4,
]
@onready var shooting_point := [
	%ShootingPoint1,
	%ShootingPoint2,
	%ShootingPoint3,
	%ShootingPoint4,
]
@onready var explosion_timer : Timer = %ExplosionTimer
@onready var shoot_timer : Timer = %ShootTimer


func _ready() -> void:
	explosion_time = randf_range(3, 6)
	explosion_timer.wait_time = explosion_time
	shoot_timer.wait_time = randf_range(1.0, 3.0)


func shoot(laser_idx: int, shoot_idx: int) -> void:
	var laser : PackedScene = lasers[laser_idx]

	var l : ShipLasers = laser.instantiate()
	l.look_here = shoot_towards[shoot_idx].global_position
	get_tree().root.add_child(l)
	l.global_position = shooting_point[shoot_idx].global_position
	l.direction = shooting_point[shoot_idx].global_position.direction_to(shoot_towards[shoot_idx].global_position)


func _on_explosion_timer_timeout() -> void:
	var ind := randi_range(0, 2)
	explosion_points[ind].explode()


func _on_shoot_timer_timeout() -> void:
	var shoot_idx := randi_range(0, 3)
	var laser_idx := randi_range(0, 2)

	shoot(laser_idx, shoot_idx)
	await get_tree().create_timer(0.1).timeout
	shoot(laser_idx, shoot_idx)
	await get_tree().create_timer(0.1).timeout
	shoot(laser_idx, shoot_idx)
	await get_tree().create_timer(0.2).timeout
	shoot(laser_idx, shoot_idx)
	await get_tree().create_timer(0.2).timeout
	shoot(laser_idx, shoot_idx)


	shoot_timer.wait_time = randf_range(0.5, 3.0)
