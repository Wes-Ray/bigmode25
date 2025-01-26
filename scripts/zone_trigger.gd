extends Area3D
class_name ZoneTrigger

@export var zone_name := ZoneName.NONE

func _on_area_entered(area:Area3D) -> void:
	print("TEST zone entered by area")
	if not area.is_in_group("ship"):
		pass
	print("ship entered zone trigger")
	var area_parent := area.get_parent()
	assert(area_parent is Ship)
	var ship: Ship = area_parent

	ship.entered_zone_trigger(zone_name)
