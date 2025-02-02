extends Node3D

@export var NORMAL_CLOSING_DISTANCE := 450
@export var MIN_CLOSE_SPEED := 0.75
@export var MAX_CLOSE_SPEED := 2.5 

var crystal_count := 0
var ship : Ship
var gate_crossed := false

func _ready():
	for node in get_children():
		if node is Crystal:
			# print("found crystal")
			crystal_count += 1
			node.destroyed.connect(_crystal_destroyed)

func _crystal_destroyed():
	crystal_count -= 1
	if crystal_count == 1:
		$AnimationPlayer.play("shield_low")
	elif crystal_count <= 0:
		ship = get_tree().get_first_node_in_group("ship")
		var distance : float = get_distance(ship.global_position)
		print(distance, " from door")

		$AnimationPlayer.speed_scale = lerp(MIN_CLOSE_SPEED, MAX_CLOSE_SPEED, clampf((NORMAL_CLOSING_DISTANCE - distance), 0, NORMAL_CLOSING_DISTANCE) / NORMAL_CLOSING_DISTANCE)
		$AnimationPlayer.play("shut_door")


func get_distance(pos: Vector3) -> float:
	return sqrt(pow(pos.x - global_position.x, 2) + pow(pos.y - global_position.y, 2) + pow(pos.z - global_position.z, 2))

func _on_gate_closed() -> void:
	if gate_crossed:
		return
	print("FAILED TO CROSS GATE IN TIME")
	EventsBus.player_entered_zone_trigger.emit(ZoneNames.id.FAILED_TO_CROSS_GATE_IN_TIME)

func _on_area_3d_area_entered(_area:Area3D) -> void:
	print("gate crossed")
	gate_crossed = true
