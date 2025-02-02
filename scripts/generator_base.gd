extends Node3D

var aux_crystal_count := 0
var objective_doors : Array[ObjectiveDoor] = []

func _ready() -> void:
	for node in get_children():
		if node is Crystal:
			aux_crystal_count += 1
			node.destroyed.connect(_crystal_destroyed)
		if node is ObjectiveCrystal:
			node.destroyed.connect(_obj_crystal_destroyed)
		if node is ObjectiveDoor:
			objective_doors.append(node)

func _crystal_destroyed() -> void:
	aux_crystal_count -= 1

	if aux_crystal_count <= 0:
		_disable_shield()

func _disable_shield() -> void:
	$AlarmSound.play()
	$Shield.hide()
	EventsBus.player_objective_complete_trigger.emit(ZoneNames.id.SHIELD_COLLAPSE)
	call_deferred("_deferred_shield_collision_disable")

func _deferred_shield_collision_disable() -> void:
	$Shield/StaticBody3D/CollisionShape3D.disabled = true

func _obj_crystal_destroyed() -> void:
	for ob_door in objective_doors:
		ob_door.close_objective_door()
	$AlarmSound.stop()
	EventsBus.player_objective_complete_trigger.emit(ZoneNames.id.CORE_GOING_CRITICAL)
