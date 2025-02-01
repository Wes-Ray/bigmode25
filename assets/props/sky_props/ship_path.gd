extends Path3D

@export var speed := 500

@onready var child_ship : PathFollow3D = self.get_child(0)

func _process(delta: float) -> void:
	child_ship.progress += delta * speed
