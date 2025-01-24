class_name HealthComponent
extends Node

signal died

@export var max_health := 5
var current_health : int


func _ready() -> void:
	current_health = max_health


func take_damage(dmg: int) -> void:
	current_health -= dmg
	if current_health <= 0:
		died.emit()


func heal(amount: int) -> void:
	current_health += amount
	clampi(current_health, 1, max_health)


func increase_max_hp(amount: int) -> void:
	max_health += amount
	current_health += amount
