class_name LaserTurret
extends Node3D


func _process(_delta: float) -> void:
	if ship and get_distance(ship.global_position) < attack_range:
		top.look_at(ship.global_position)
		if attack_timer.is_stopped():
			shoot()
			attack_timer.start()
	else:
		ship = get_tree().get_first_node_in_group("ship")
		