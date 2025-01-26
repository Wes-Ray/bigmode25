extends Node3D

var crystal_count := 2

# Called when the node enters the scene tree for the first time.
func _ready():
	%Crystal1.destroyed.connect(_crystal_destroyed)
	%Crystal2.destroyed.connect(_crystal_destroyed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _crystal_destroyed():
	crystal_count -= 1
	if crystal_count == 1:
		$AnimationPlayer.play("shield_low")
	elif crystal_count <= 0:
		$AnimationPlayer.play("shut_door")