class_name Projectile
extends Node3D

enum {NONE, ENV = 1, PLAYER = 2, ENEMY = 4}

var speed := 200.0
var direction := Vector3(0, 0, 0)
var spawner := NONE

@onready var explosion_particles : SkyExplosion = %SkyExplosion
@onready var cylinder : CSGCylinder3D = %CSGCylinder3D


func _ready() -> void:
	if spawner == NONE:
		print("projectile spawner is NONE")
	EventsBus.game_reset.connect(queue_free)
	$Area3D.set_collision_layer(spawner)
	if spawner == PLAYER:
		$Area3D.set_collision_mask(ENV | ENEMY)
	elif spawner == ENEMY:
		$Area3D.set_collision_mask(ENV | PLAYER)


func _physics_process(delta: float) -> void:
	look_at(global_position + direction * 10000)
	rotate(Vector3(0, 1, 0), PI/2)
	global_position += direction * speed * delta


func _on_area_3d_area_entered(_area:Area3D) -> void:
	explode_projectile()
	print("hit: ", _area)


func _on_area_3d_body_entered(_body:Node3D) -> void:
	explode_projectile()
	#print("hit: ", _body)


func explode_projectile():
	speed = 0
	set_deferred("$Explosion/Area3D/CollisionShape3D.disabled", false)
	explosion_particles.explode()
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _on_timeout_timer_timeout() -> void:
	queue_free()
