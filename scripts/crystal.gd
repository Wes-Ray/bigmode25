extends Node3D 

class_name Crystal

signal destroyed
@onready var crystal_destroy_sound_player := %CrystalDestroyedSound

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_area_entered(_area:Area3D):
	destroyed.emit()
	crystal_destroy_sound_player.play()
	# print("%s destroyed" % self.name)
	self.visible = false
	call_deferred("remove_collision")

func remove_collision():
	$Area3D/CollisionShape3D.disabled = true
