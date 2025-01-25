class_name ProjectileTurret
extends Node3D

@export var attack_range := 2000
@export var projectile : PackedScene = preload("res://scenes/turrets/projectile_turret/enemy_projectile.tscn")
var attack_ready := true

@onready var attack_timer : Timer = %AttackTimer
@onready var top : Node3D = %Top
@onready var ship : Ship = get_tree().get_first_node_in_group("ship")
@onready var shooting_point : Node3D = %ShootingPoint


func _process(_delta: float) -> void:
	if ship and get_distance(ship.global_position) < attack_range:
		top.look_at(ship.global_position)
		if attack_timer.is_stopped():
			shoot()
			attack_timer.start()
	else:
		ship = get_tree().get_first_node_in_group("ship")


func shoot() -> void:
	var proj : Node3D = projectile.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = shooting_point.global_position
	proj.direction = (ship.global_position - shooting_point.global_position).normalized()


func get_distance(pos: Vector3) -> float:
	return sqrt(pow(pos.x - global_position.x, 2) + pow(pos.y - global_position.y, 2) + pow(pos.z - global_position.z, 2))
