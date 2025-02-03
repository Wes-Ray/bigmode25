extends Node3D

var ship : Ship


func _process(_delta: float) -> void:
	if is_instance_valid(ship):
		if ship.global_position.y > global_position.y:
			EventsBus.ceiling_warning_started.emit()
			if ship.global_position.y > global_position.y + 40.:
				ship.blow_up_player()
		else:
			EventsBus.ceiling_warning_stopped.emit()
	else:
		ship = get_tree().get_first_node_in_group("ship")
