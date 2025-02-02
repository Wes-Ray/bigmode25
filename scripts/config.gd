extends Node

@export var mouse_sens :float= 1.1
@export var mouse_inverted :bool= false
@export var full_screen :bool= false

@onready var sfx_volume := 50.0
@onready var music_volume := 50.0
@onready var voice_volume := 50.0


func convert_percentage_to_decibels(percent: float) -> float:
    var scale : float = 20.0
    var divisor : float = 50.0
    return scale * log(percent / divisor) / log(10)
	