extends Marker3D
class_name ProxZone

@export var zone_trigger_entrance : ZoneTrigger

@onready var main_parent: MainLevel = get_parent()

func _ready() -> void:
	assert(zone_trigger_entrance, "zone entrance must be defined in editor")
	assert(main_parent is MainLevel, "prox zones need to be direct child to a MainLevel")
	zone_trigger_entrance.area_entered.connect(_area_entered)
	disable_children()
	
func _area_entered(area: Area3D) -> void:
	if not area.is_in_group("ship"):
		return

	print("entering new proximity zone")

	# disable any other prox zones
	if main_parent.active_prox_zone:
		main_parent.active_prox_zone.disable_children()
	main_parent.active_prox_zone = self

	# TODO: if there are errors with lights not being enabled, might want to make a timer here
	call_deferred("enable_children")

func disable_children():
	print("disabling children")
	for c in get_children():
		if c is not Node3D:
			print("non-node3d found in disable children: ", c)
			continue
		if c is ZoneTrigger:
			continue
		c.process_mode = Node.PROCESS_MODE_DISABLED
		c.visible = false

func enable_children():
	print("enabling children")
	for c in get_children():
		if c is not Node3D:
			print("non-node3d found in enable children: ", c)
			continue
		if c is ZoneTrigger:
			continue
		c.process_mode = Node.PROCESS_MODE_INHERIT
		c.visible = true
