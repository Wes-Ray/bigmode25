class_name LaserTurret
extends Node3D

@export var attack_range := 2000
var ship : Ship

@onready var laser : Node3D = %Laser
@onready var attack_timer : Timer = %AttackTimer
@onready var top : Node3D = %Top
@onready var shooting_point : Node3D = %ShootingPoint
@onready var anim_player : AnimationPlayer = %AnimationPlayer
@onready var laser_hum_sound_mover : SpringArm3D = %SpringArm3D
@onready var laser_hum_sound : AudioStreamPlayer3D = %LaserHumSound


func _ready() -> void:
	laser.get_node("Cylinder").scale.y = attack_range
	laser.get_node("Area3D/CollisionShape3D").shape.height = attack_range
	laser.position.z -= attack_range

	laser_hum_sound.pitch_scale += randf_range(-1, 1)

	anim_player.play("up-down")


func _physics_process(_delta: float) -> void:
	if ship:
		var dist := get_distance(ship.global_position)
		laser_hum_sound_mover.spring_length = dist
	else:
		ship = get_tree().get_first_node_in_group("ship")
		


func _on_area_3d_area_entered(_area:Area3D) -> void:
	print("laser turret hit")

func get_distance(pos: Vector3) -> float:
	return sqrt(pow(pos.x - global_position.x, 2) + pow(pos.y - global_position.y, 2) + pow(pos.z - global_position.z, 2))
