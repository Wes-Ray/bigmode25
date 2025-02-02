extends Node3D
class_name MainLevel

@export var spawn_point: Marker3D
@export var debug_spawn_point: Marker3D
@export var debug_checkpoint: Checkpoint.id
@export var ship_scene: PackedScene
@export var camera_scene: PackedScene
@export var hud_scene: PackedScene
var sky_chaos : Node3D

@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var cave_world_env_res := preload("res://resources/cave_world_environment.tres")
@onready var canyon_world_env_res := preload("res://resources/canyon_run_world_environment.tres")
@onready var sky_chaos_packed := preload("res://scenes/sky_scenes/sky_chaos.tscn")
@onready var cave_directional_light: DirectionalLight3D = %CaveDirectionalLight
@onready var canyon_directional_light: DirectionalLight3D = %CanyonDirectionalLight

# Music
@onready var cave_ost := preload("res://assets/sound/CaveSound.mp3")
# @onready var

# player object refs
var ship_instance: Ship
var camera_instance: CameraRig
var hud_instance: HUD

var sky_debug := false

# For use by ProxZone direct children
var active_prox_zone: ProxZone = null

func _ready() -> void:
	assert(spawn_point, "spawn point must be assigned to main script")
	assert(ship_scene, "ship must be assigned")
	assert(hud_scene, "HUD must be assigned")
	assert(camera_scene, "camera must be assigned")

	if OS.is_debug_build() and debug_spawn_point:
	# if debug_spawn_point:
		spawn_point = debug_spawn_point
	
	if OS.is_debug_build() and debug_checkpoint != Checkpoint.id.START:
		Checkpoint.current_checkpoint = debug_checkpoint

	
	print("loading checkpoint: ", Checkpoint.current_checkpoint)
	match Checkpoint.current_checkpoint:
		Checkpoint.id.START:
			pass
		Checkpoint.id.ENTERING_CANYON:
			spawn_point = %ProxZone03EnteringCanyon
		Checkpoint.id.FAST_SHOOT_TURRETS:
			spawn_point = %SpawnAfterFastShootTurrets
		Checkpoint.id.BEFORE_CHASE:
			spawn_point = %SpawnBeforeChase
			%generator_base._obj_crystal_destroyed()

	sky_chaos = sky_chaos_packed.instantiate()

	init()

# func _process(_delta: float) -> void:
# 	if Input.is_action_just_released("debug1"):
# 		switch_to_cave_world_environment()
# 	if Input.is_action_just_released("debug2"):
# 		switch_to_canyon_world_environment()
	# if sky_debug:
	# 	Logger.log("tree: ", get_tree().root.get_children())

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

	add_child(sky_chaos)
	sky_chaos.global_position = Vector3.ZERO
	# sky_debug = true

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
	ship_instance.player_failed_to_reach_gate.connect(hud_instance.on_player_failed_to_reach_gate)
	ship_instance.player_crashed.connect(camera_instance.on_player_crashed)
	ship_instance.player_failed_to_reach_gate.connect(camera_instance.on_player_failed_to_reach_gate)

	hud_instance.player_ref = ship_instance

	add_child(ship_instance)
	add_child(camera_instance)
	add_child(hud_instance)

	EventsBus.player_entered_zone_trigger.connect(_on_player_entered_zone_trigger)
	EventsBus.player_objective_complete_trigger.connect(_on_player_entered_zone_trigger)
	EventsBus.player_failed_chase.connect(ship_instance._died)

	hud_instance.pause()

# When player enters a zone, it will send a node with a ZoneNames ENUM
func _on_player_entered_zone_trigger(zone_name: int):
	print("player entered zone trigger: ", zone_name)
	
	match zone_name:
		# PRIMARY ZONES
		ZoneNames.id.NONE:
			pass
		ZoneNames.id.ENTERING_CAVE:
			camera_instance.cave_soundtrack.play()
		ZoneNames.id.SPAWN_CAVE:
			print("spawn cave")
			switch_to_cave_world_environment()
		ZoneNames.id.ENTERING_CANYON:
			print("entering canyon")
			switch_to_canyon_world_environment()
			Checkpoint.current_checkpoint = Checkpoint.id.ENTERING_CANYON
		ZoneNames.id.FIRST_CANYON_GATE:
			camera_instance.canyon_soundtrack.play()
		ZoneNames.id.BEFORE_FAST_SHOOT_TURRETS:
			if not camera_instance.canyon_soundtrack.playing:
				camera_instance.canyon_soundtrack.play()
		ZoneNames.id.FAST_SHOOT_TURRETS:
			Checkpoint.current_checkpoint = Checkpoint.id.FAST_SHOOT_TURRETS
		ZoneNames.id.ENTERING_BOSS_AREA:
			camera_instance.canyon_soundtrack.stop()
			camera_instance.boss_soundtrack.play()
		ZoneNames.id.ENTERING_FINAL_RUN:
			camera_instance.boss_soundtrack.stop()
			camera_instance.final_run_soundtrack.play()
			hud_instance.activate_chase_timer()
			switch_to_cave_world_environment()
			ship_instance.chase_rumble_sound.play()
			Checkpoint.current_checkpoint = Checkpoint.id.BEFORE_CHASE
		
		# ALLY VOICE TRIGGERS
		ZoneNames.id.COMMS_CHECK:
			camera_instance.radio_box.play_ally_radio("intro1_readleader")
		ZoneNames.id.REVIEWED_CONOP:
			camera_instance.radio_box.play_ally_radio("intro2_readleader")
		ZoneNames.id.JERRY_RIGGED:
			camera_instance.radio_box.play_ally_radio("firstgate1_redleader")
		ZoneNames.id.WEAPONS_FREE:
			camera_instance.radio_box.play_ally_radio("firstgate2_redleader")
		# called from tutorial zone activation by shooting tutorial gate
		ZoneNames.id.GATE_CYCLING:
			camera_instance.radio_box.play_ally_radio("firstgate3_redleader")
			hud_instance.play_tutorial("shift to boost")
		# TODO: maybe move this to the last chase sequence?
		ZoneNames.id.THREAD_NEEDLE:
			camera_instance.radio_box.play_ally_radio("firstgate4_readleader")
		ZoneNames.id.CLEAN_INSERTION:
			camera_instance.radio_box.play_ally_radio("exiting1_redleader")
		ZoneNames.id.DEFENSE_POWER_ON:
			camera_instance.radio_box.play_ally_radio("exiting2_redleader")
		ZoneNames.id.MAIN_GENERATOR_TWO_KLICKS:
			camera_instance.radio_box.play_ally_radio("midway 1_redleader")
		ZoneNames.id.FOUR_POWER_CRYSTALS:
			camera_instance.radio_box.play_ally_radio("entering1_redleader")
		ZoneNames.id.SHIELD_COLLAPSE:
			camera_instance.radio_box.play_ally_radio("entering2_redleader")
		ZoneNames.id.CORE_GOING_CRITICAL:
			camera_instance.radio_box.play_ally_radio("entering3_redleader")
		ZoneNames.id.MOVE_IT_PRISM:
			camera_instance.radio_box.play_ally_radio("move it prism one")
		ZoneNames.id.COME_ON_PRISM:
			camera_instance.radio_box.play_ally_radio("comeon2_redleader")
		ZoneNames.id.T_MINUS_30:
			camera_instance.radio_box.play_ally_radio("core meltdown")
		ZoneNames.id.OUTSTANDING_WORK:
			camera_instance.radio_box.play_ally_radio("escaping1_redleader")
			hud_instance.deactivate_chase_timer()
		ZoneNames.id.GATE_SEALED:
			camera_instance.radio_box.play_ally_radio("doorshut1_redleader")
		ZoneNames.id.TOO_HIGH:
			camera_instance.radio_box.play_ally_radio("toohigh1_redleader")
		ZoneNames.id.DEATH_VARIANT:
			var rand_select := randi_range(0, 2)
			match rand_select:
				0:
					camera_instance.radio_box.play_ally_radio("death1_redleader")
				1:
					camera_instance.radio_box.play_ally_radio("death2_redleader")
				2:
					camera_instance.radio_box.play_ally_radio("death3_redleader")
		
		# TUTORIAL TRIGGERS
		ZoneNames.id.TUT_BOOST:
			hud_instance.play_tutorial("shift to boost")
		ZoneNames.id.TUT_ROLL:
			hud_instance.play_tutorial("a/d to roll")
		ZoneNames.id.TUT_SHOOT:
			hud_instance.play_tutorial("click to shoot")
		ZoneNames.id.TUT_POWER_MANAGEMENT:
			hud_instance.play_tutorial("your ship only has enough power to shoot or boost, not both")
		
		# MISSION TRIGGERS
		ZoneNames.id.FAILED_TO_CROSS_GATE_IN_TIME:
			hud_instance.play_tutorial("failed to breach security gate in time")
			camera_instance.radio_box.play_ally_radio("doorshut1_redleader")
			await get_tree().create_timer(4.).timeout
			ship_instance.failed_to_reach_gate()
		ZoneNames.id.PLAYER_REACH_END:
			switch_to_canyon_world_environment()
			await get_tree().create_timer(7.).timeout
			hud_instance.player_reached_end()
		ZoneNames.id.FIRST_DOOR:
			camera_instance.radio_box.play_enemy_radio("1st blast door")
		ZoneNames.id.ANOTHER_DOOR:
			camera_instance.radio_box.play_enemy_radio("another blast door")
		ZoneNames.id.HIT_ANYTHING:
			camera_instance.radio_box.play_enemy_radio("can you hit anything")
		ZoneNames.id.DIE_SCUM:
			camera_instance.radio_box.play_enemy_radio("DIE SCUM")
		ZoneNames.id.WONT_LIVE:
			camera_instance.radio_box.play_enemy_radio("he wont live through the explosion")
		ZoneNames.id.SURVIVE_GENERATOR:
			camera_instance.radio_box.play_enemy_radio("he wont survive the generator room")
		ZoneNames.id.GOING_FOR_CRYSTALS:
			camera_instance.radio_box.play_enemy_radio("Hes going for the cystals")
		ZoneNames.id.TOO_FAST:
			camera_instance.radio_box.play_enemy_radio("hes too fast")
		ZoneNames.id.DO_IT_MYSELF:
			camera_instance.radio_box.play_enemy_radio("Ill do it myself")
		ZoneNames.id.LOOK_ALIVE:
			camera_instance.radio_box.play_enemy_radio("look alive")
		ZoneNames.id.MOTION_DETECTED:
			camera_instance.radio_box.play_enemy_radio("motion detected")
		ZoneNames.id.STOP_THIS_GUY:
			camera_instance.radio_box.play_enemy_radio("somebody stop this guy")
		ZoneNames.id.STATION_COMING_DOWN:
			camera_instance.radio_box.play_enemy_radio("stations coming down")
		ZoneNames.id.SURVIVE_THIS:
			camera_instance.radio_box.play_enemy_radio("try to survive this")
		ZoneNames.id.HELL_WAS_THAT:
			camera_instance.radio_box.play_enemy_radio("what the hell was that")

		_:
			assert(false, "unhandled ZoneNames.id was passed to the ship from a zone entrance")
