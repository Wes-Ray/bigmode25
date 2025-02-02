extends Area3D
class_name ZoneTrigger

@export var zone_name : ZoneNames.id = ZoneNames.id.NONE

func _on_area_entered(area:Area3D) -> void:
	if not area.is_in_group("ship"):
		return

	var area_parent := area.get_parent()
	assert(area_parent is Ship, "area collided isn't a ship")

	EventsBus.player_entered_zone_trigger.emit(zone_name)

	# print("ENTERING ZONE TRIGGER")
	call_deferred("disable_self")

func disable_self() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
