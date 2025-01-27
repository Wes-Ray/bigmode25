extends Area3D
class_name ZoneTrigger

@export var zone_name : ZoneName.id = ZoneName.id.NONE

func _on_area_entered(area:Area3D) -> void:
	if not area.is_in_group("ship"):
		return

	var area_parent := area.get_parent()
	assert(area_parent is Ship, "area collided isn't a ship")
	var ship: Ship = area_parent

	ship.entered_zone_trigger(zone_name)
	call_deferred("disable_self")

func disable_self() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	