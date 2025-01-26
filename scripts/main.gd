extends Node3D

@export var spawn_point: Node3D
@export var debug_spawn_point: Node3D
@export var ship_scene: PackedScene
@export var camera_scene: PackedScene
@export var hud_scene: PackedScene

# TEST DEBUG
@onready var bulb1a :OmniLight3D= %testbulb1a
@onready var bulb1b :OmniLight3D= %testbulb1b
@onready var bulb2a :OmniLight3D= %testbulb2a
@onready var bulb2b :OmniLight3D= %testbulb2b
@onready var props := %Props

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(spawn_point, "spawn point must be assigned to main script")
	assert(ship_scene, "ship must be assigned")
	assert(hud_scene, "HUD must be assigned")
	# print("main _ready called")

	if OS.is_debug_build() and debug_spawn_point:
		spawn_point = debug_spawn_point

	init()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		print("---------------------------------------")
		print("1 ENABLED")
		# print("bulb1a", bulb1a)
		# bulb1a.visible = true
		# bulb1b.visible = true
		bulb1a.process_mode = Node.PROCESS_MODE_INHERIT
		bulb1b.process_mode = Node.PROCESS_MODE_INHERIT
		# props.visible = true
		# props.process_mode = Node.PROCESS_MODE_INHERIT
	elif Input.is_action_just_released("debug1"):
		print("#######################################")
		print("1 disabled")
		# bulb1a.visible = false
		# bulb1b.visible = false
		bulb1a.process_mode = Node.PROCESS_MODE_DISABLED
		bulb1b.process_mode = Node.PROCESS_MODE_DISABLED
		# props.visible = false
		# props.process_mode = Node.PROCESS_MODE_DISABLED

	if Input.is_action_just_pressed("debug2"):
		print("2 ENABLED")
		# bulb2a.visible = true
		# bulb2b.visible = true
		bulb2a.process_mode = Node.PROCESS_MODE_INHERIT
		bulb2b.process_mode = Node.PROCESS_MODE_INHERIT
	elif Input.is_action_just_released("debug2"):
		print("2 disabled")
		# bulb2a.visible = false
		# bulb2b.visible = false
		bulb2a.process_mode = Node.PROCESS_MODE_DISABLED
		bulb2b.process_mode = Node.PROCESS_MODE_DISABLED

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
