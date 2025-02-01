extends Node3D

var aux_crystal_count := 0
var objective_doors : Array[ObjectiveDoor] = []

func _ready() -> void:
	for node in get_children():
		if node is Crystal:
			print("found aux crystal")
			aux_crystal_count += 1
			node.destroyed.connect(_crystal_destroyed)
		if node is ObjectiveCrystal:
			print("found obj crystal")
			node.destroyed.connect(_obj_crystal_destroyed)
		if node is ObjectiveDoor:
			objective_doors.append(node)

func _crystal_destroyed() -> void:
	print("aux crystal destroyed")
	aux_crystal_count -= 1

	if aux_crystal_count <= 0:
		_disable_shield()

func _disable_shield() -> void:
	print("disabling obj shield")
	$AlarmSound.play()
	$Shield.hide()
	call_deferred("_deferred_shield_collision_disable")

func _deferred_shield_collision_disable() -> void:
	$Shield/StaticBody3D/CollisionShape3D.disabled = true

func _obj_crystal_destroyed() -> void:
	print("obj crystal destroyed")
	for ob_door in objective_doors:
		ob_door.close_objective_door()
	$AlarmSound.stop()
