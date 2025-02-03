extends CharacterBody3D

# Animation parameters
@export var hover_height: float = 0.5  # Maximum height of hover
@export var hover_speed: float = 2.0   # Speed of vertical motion
@export var pitch_amount: float = 0.1  # Maximum pitch rotation (radians)
@export var roll_amount: float = 0.1   # Maximum roll rotation (radians)
@export var bob_amount: float = 0.3    # Forward/backward movement amount
@export var rotation_speed: float = 1.5 # Speed of rotation animations

# Starting position
var initial_position: Vector3
var time: float = 0.0

func _ready():
    # Store the initial position to use as center point
	initial_position = position

func _physics_process(delta):
	time += delta

	# Vertical hovering motion (up/down)
	var hover = sin(time * hover_speed) * hover_height

	# Pitch (forward/backward rotation)
	var pitch = sin(time * rotation_speed) * pitch_amount

	# Roll (left/right rotation)
	var roll = cos(time * rotation_speed * 1.3) * roll_amount

	# Forward/backward position bobbing
	var bob = sin(time * rotation_speed * 0.8) * bob_amount

	# Apply all movements
	position = initial_position + Vector3(0, hover, bob)

	# Create rotation transform
	var rotation_transform = Transform3D()
	rotation_transform = rotation_transform.rotated(Vector3.RIGHT, pitch)
	rotation_transform = rotation_transform.rotated(Vector3.FORWARD, roll)

	# Apply rotation
	transform.basis = rotation_transform.basis
