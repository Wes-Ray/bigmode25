extends Node3D 

class_name ObjectiveCrystal

signal destroyed
@onready var crystal_destroy_sound_player := %CrystalDestroyedSound

func _on_area_3d_area_entered(_area:Area3D):
	destroyed.emit()
	crystal_destroy_sound_player.play()
	# print("%s destroyed" % self.name)
	self.visible = false
	call_deferred("remove_collision")

func remove_collision():
	$Area3D/CollisionShape3D.disabled = true
