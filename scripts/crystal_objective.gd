extends Node3D 

class_name ObjectiveCrystal

signal destroyed
@onready var crystal_destroy_sound_player := %CrystalDestroyedSound
@onready var explosion : SkyExplosion = %SkyExplosion
@onready var crystal : Node3D = %big_crystal


func _on_area_3d_area_entered(_area:Area3D):
	destroyed.emit()
	crystal_destroy_sound_player.play()
	# print("%s destroyed" % self.name)
	crystal.hide()

	call_deferred("remove_collision")
	
	explosion.explode()

func remove_collision():
	$Area3D/CollisionShape3D.disabled = true
