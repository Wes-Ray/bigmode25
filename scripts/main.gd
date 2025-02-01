extends Node3D
class_name MainLevel

@export var spawn_point: Marker3D
@export var debug_spawn_point: Marker3D
@export var ship_scene: PackedScene
@export var camera_scene: PackedScene
@export var hud_scene: PackedScene

@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var cave_world_env_res := preload("res://resources/cave_world_environment.tres")
@onready var canyon_world_env_res := preload("res://resources/canyon_run_world_environment.tres")
@onready var cave_directional_light: DirectionalLight3D = %CaveDirectionalLight
@onready var canyon_directional_light: DirectionalLight3D = %CanyonDirectionalLight

# Music
@onready var cave_ost := preload("res://assets/sound/CaveSound.mp3")
# @onready var

# player object refs
var ship_instance: Ship
var camera_instance: CameraRig
var hud_instance: HUD

# For use by ProxZone direct children
var active_prox_zone: ProxZone = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(spawn_point, "spawn point must be assigned to main script")
	assert(ship_scene, "ship must be assigned")
	assert(hud_scene, "HUD must be assigned")
	assert(camera_scene, "camera must be assigned")
	# print("main _ready called")

	# if OS.is_debug_build() and debug_spawn_point:
	if debug_spawn_point:
		spawn_point = debug_spawn_point

	init()

func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug1"):
		switch_to_cave_world_environment()
	if Input.is_action_just_released("debug2"):
		switch_to_canyon_world_environment()

func switch_to_cave_world_environment() -> void:
	print("cave world env")
	world_environment.environment = cave_world_env_res
	cave_directional_light.show()
	canyon_directional_light.hide()

func switch_to_canyon_world_environment() -> void:
	print("canyon world env")
	world_environment.environment = canyon_world_env_res
	cave_directional_light.hide()
	canyon_directional_light.show()

func init() -> void:
	ship_instance = ship_scene.instantiate()
	camera_instance = camera_scene.instantiate()
	hud_instance = hud_scene.instantiate()
	
	# spider-man meme all nodes pointing to each other
	ship_instance.camera_rig = camera_instance
	ship_instance.hud = hud_instance

	camera_instance.hud = hud_instance 
	camera_instance.track_target = ship_instance
	
	hud_instance.player_ref = ship_instance
	hud_instance.camera_rig = camera_instance

	ship_instance.position = spawn_point.position
	camera_instance.position = spawn_point.position
	ship_instance.rotation = spawn_point.rotation
	camera_instance.rotation = spawn_point.rotation

	ship_instance.player_crashed.connect(hud_instance.on_player_crashed)
	ship_instance.player_crashed.connect(camera_instance.on_player_crashed)

	hud_instance.player_ref = ship_instance

	add_child(ship_instance)
	add_child(camera_instance)
	add_child(hud_instance)

	EventsBus.player_entered_zone_trigger.connect(_on_player_entered_zone_trigger)

	hud_instance.pause()

# When player enters a zone, it will send a node with a ZoneName ENUM
func _on_player_entered_zone_trigger(zone_name: int):
	print("player entered zone trigger: ", zone_name)
	
	match zone_name:
		ZoneName.id.NONE:
			pass
		ZoneName.id.ENTERING_CAVE:
			camera_instance.cave_soundtrack.play()
		ZoneName.id.SPAWN_CAVE:
			print("spawn cave")
			switch_to_cave_world_environment()
		ZoneName.id.ENTERING_CANYON:
			print("entering canyon")
			switch_to_canyon_world_environment()
		ZoneName.id.FIRST_CANYON_GATE:
			camera_instance.canyon_soundtrack.play()
		_:
			assert(false, "unhandled ZoneName.id was passed to the ship from a zone entrance")
