extends Node3D

var ship : Ship


func _ready() -> void:
	EventsBus.ceiling_height_reached.connect(_show_laser)
	get_child(0).hide()


func _process(_delta: float) -> void:
	if not is_instance_valid(ship):
		ship = get_tree().get_first_node_in_group("ship")
		return
	
	global_position.x = ship.global_position.x
	global_position.z = ship.global_position.z


func _show_laser() -> void:
	get_child(0).show()
