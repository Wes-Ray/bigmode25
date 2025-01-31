class_name LaserTurret
extends Node3D

# @export var attack_range := 1000.
@export var attack_range := 400.
@export var laser_thickness := 14.
var ship : Ship

@onready var lasers : Array[Node3D] = [
	%ShootingPoint1/Laser, 
	%ShootingPoint2/Laser, 
	%ShootingPoint3/Laser, 
	%ShootingPoint4/Laser, 
	%ShootingPoint5/Laser
	]
@onready var shooting_positions :Array[Node3D]= [
	%ShootingPoint1,
	%ShootingPoint2,
	%ShootingPoint3,
	%ShootingPoint4,
	%ShootingPoint5,
	]
@onready var attack_timer : Timer = %AttackTimer
@onready var yaw_rig : Node3D = %YawRig
@onready var pitch_rig := %PitchRig
@onready var shooting_point : Node3D = %ShootingPoint1
@onready var anim_player : AnimationPlayer = %AnimationPlayer
@onready var laser_hum_sound_mover : SpringArm3D = %SpringArm3D
@onready var laser_hum_sound : AudioStreamPlayer3D = %LaserHumSound
@onready var laser_init_sound: AudioStreamPlayer3D = %LaserInitChargeSound

@onready var player_looker := %PlayerLooker
@onready var player_raycast := %PlayerRaycast

@export var firing :bool= false  # for animation player
@export var current_pitch :float= 0.  # for animation player

func _ready() -> void:
	for laser in lasers:
		# laser.spring_length = attack_range
		laser.get_node("Area3D/CollisionShape3D").shape.set_radius(laser_thickness)
		laser.get_node("Area3D/CollisionShape3D").shape.set_height(attack_range)
		laser.get_node("Cylinder").height = attack_range
		laser.get_node("Cylinder").radius = laser_thickness 
		laser.position.z -= attack_range / 2.
	
	# lasers[2].get_node("SpringArm3D").spring_length = attack_range * 2

	laser_hum_sound.pitch_scale += randf_range(-1, 0.2)
	done_firing_laser()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(ship):
		ship = get_tree().get_first_node_in_group("ship")
		return

	# Logger.log("spring", lasers[2].get_node("SpringArm3D").spring_length)

	var dist := get_distance(ship.global_position)
	laser_hum_sound_mover.spring_length = dist

	player_raycast.target_position = ship.global_position
	
	# TODO: clean this up, right now it's just seeing if it gets any valid collider which seems
	#       to work as needed, but might cause issues if other objects get in the way
	var see_player := false
	if is_instance_valid(player_raycast.get_collider()):
		# see_player = player_raycast.get_collider()
		see_player = true
		
	Logger.log("raycast", see_player)

	if see_player:
		if not anim_player.current_animation == "up-down":
			# fire_laser()
			anim_player.play("up-down")
	else:
		if anim_player.current_animation == "up-down":
			done_firing_laser()

	if not firing:
		player_looker.look_at(ship.position)
		Logger.log("player_looker", player_looker.rotation_degrees.x)
		yaw_rig.rotation.y = player_looker.rotation.y
	
	# pitch_rig.rotation.x = current_pitch
	# for laser in lasers:
		# laser.rotation.x = current_pitch
	for sp in shooting_positions:
		sp.rotation.x = current_pitch
	# for laser in lasers:
	# 	# laser.get_node("Cylinder").height = laser.spring_length
	# 	laser.get_node("Cylinder").height = 200
	
	# Logger.log("laser0", lasers[2].spring_length)

func _on_area_3d_area_entered(_area:Area3D) -> void:
	print("laser turret hit")

func fire_laser():
	# print("print laser")
	pitch_rig.show()
	laser_init_sound.play()
	laser_hum_sound.play()
	anim_player.play("up-down")
	pitch_rig.process_mode = Node.PROCESS_MODE_INHERIT

func done_firing_laser():
	# print("finished firing")
	laser_init_sound.stop()
	laser_hum_sound.stop()
	pitch_rig.hide()
	# anim_player.play("RESET")
	pitch_rig.process_mode = Node.PROCESS_MODE_DISABLED


func get_distance(pos: Vector3) -> float:
	return sqrt(pow(pos.x - global_position.x, 2) + pow(pos.y - global_position.y, 2) + pow(pos.z - global_position.z, 2))
