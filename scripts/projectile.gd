class_name Projectile
extends Node3D

var speed := 200.0
var direction := Vector3(0, 0, 0)

@onready var cylinder : CSGCylinder3D = %CSGCylinder3D


func _ready() -> void:
	EventsBus.game_reset.connect(queue_free)


func _physics_process(delta: float) -> void:
	look_at(global_position + direction * 10000)
	rotate(Vector3(0, 1, 0), PI/2)
	global_position += direction * speed * delta


func _on_area_3d_body_entered(_body:Node3D) -> void:
	speed = 0
	#print("hit: ", _body)
	set_deferred("$Explosion/Area3D/CollisionShape3D.disabled", false)
	$Explosion.visible = true
	await get_tree().create_timer(0.2).timeout
	queue_free()


func _on_timeout_timer_timeout() -> void:
	queue_free()
