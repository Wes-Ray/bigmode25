extends Area3D

var prox_objects : Array[ProxObject] = []

func _on_area_entered(area:Area3D) -> void:
	if area is not ProxObject:
		return
	
	var new_obj: ProxObject = area
	prox_objects.append(new_obj)

	# print("---------------------")
	# for p in prox_objects:
	# 	p.disable_parent()
