class_name LaserTurret
extends Node3D

@export var attack_range := 2000

@onready var attack_timer : Timer = %AttackTimer
@onready var ship : Ship = get_tree().get_first_node_in_group("ship")
@onready var top : Node3D = %Top


func _process(_delta: float) -> void:
	if ship and get_distance(ship.global_position) < attack_range:
		top.look_at(ship.global_position)
		if attack_timer.is_stopped():
			shoot()
			attack_timer.start()
	else:
		ship = get_tree().get_first_node_in_group("ship")


func shoot() -> void:
	pass

func get_distance(pos: Vector3) -> float:
	return sqrt(pow(pos.x - global_position.x, 2) + pow(pos.y - global_position.y, 2) + pow(pos.z - global_position.z, 2))
