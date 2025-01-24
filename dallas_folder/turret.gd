class_name Turret
extends Node3D



@onready var top : Node3D = %Top
@onready var ship : Ship = get_tree().get_first_node_in_group("ship")
@onready var range := EnemyVariables.turret_range


func _process(_delta: float) -> void:
	if ship:
		top.look_at(ship.global_position)
