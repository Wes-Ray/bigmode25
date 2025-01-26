extends MeshInstance3D

signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_area_entered(_area:Area3D):
	destroyed.emit()
	self.visible = false
	set_deferred("$Area3D/CollisionShape3D.disabled", true)