extends Node3D

var aux_crystal_count := 0

func _ready() -> void:
	for node in get_children():
		if node is Crystal:
			print("found aux crystal")
			aux_crystal_count += 1
			node.destroyed.connect(_crystal_destroyed)
		if node is ObjectiveCrystal:
			print("found obj crystal")
			node.destroyed.connect(_obj_crystal_destroyed)

func _crystal_destroyed() -> void:
	print("aux crystal destroyed")
	aux_crystal_count -= 1

	if aux_crystal_count <= 0:
		print("BOOM CHACA LACA")

func _obj_crystal_destroyed() -> void:
	print("obj crystal destroyed")