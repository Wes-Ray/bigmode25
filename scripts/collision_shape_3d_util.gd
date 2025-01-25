extends CollisionShape3D

# This script makes the shape assigned to this collision shape unique and then enables backface collision.
# This is useful for the tunnels in this game.

func _ready() -> void: 
	self.shape = self.shape.duplicate()
	self.shape.backface_collision = true
