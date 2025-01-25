class_name LaserTurret
extends Node3D

@export var attack_range := 2000

@onready var laser : Node3D = %Laser
@onready var attack_timer : Timer = %AttackTimer
@onready var top : Node3D = %Top
@onready var shooting_point : Node3D = %ShootingPoint
@onready var anim_player : AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	laser.get_node("Cylinder").scale.y = attack_range
	laser.get_node("Area3D/CollisionShape3D").shape.height = attack_range
	laser.position.z -= attack_range

	anim_player.play("up-down")


func _on_area_3d_area_entered(area:Area3D) -> void:
	Logger.log("laser turret hit", area.name)
	print("laser turret hit")
