extends Node3D

@export var spawn_point: Node3D
@export var debug_spawn_point: Node3D
@export var ship_scene: PackedScene
@export var camera_scene: PackedScene
@export var hud_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(spawn_point, "spawn point must be assigned to main script")
	assert(ship_scene, "ship must be assigned")
	assert(hud_scene, "HUD must be assigned")
	# print("main _ready called")

	if OS.is_debug_build() and debug_spawn_point:
		spawn_point = debug_spawn_point

	init()

func init() -> void:
	var ship_instance: Ship = ship_scene.instantiate()
	var camera_instance: CameraRig = camera_scene.instantiate()
	var hud_instance: HUD = hud_scene.instantiate()
	
	ship_instance.camera_rig = camera_instance
	camera_instance.track_target = ship_instance

	ship_instance.position = spawn_point.position
	camera_instance.position = spawn_point.position
	ship_instance.rotation = spawn_point.rotation
	camera_instance.rotation = spawn_point.rotation

	ship_instance.player_crashed.connect(hud_instance.on_player_crashed)

	add_child(ship_instance)
	add_child(camera_instance)
	add_child(hud_instance)

	hud_instance.pause()
