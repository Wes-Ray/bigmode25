extends Area3D

func _on_area_entered(area:Area3D) -> void:
	print("prox area: ", area.get_groups())
