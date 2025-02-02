extends Node3D


@onready var ally_radio :AudioStreamPlayer3D= %AllyRadio
@onready var enemy_radio :AudioStreamPlayer3D= %EnemyRadio

func play_enemy_radio(file_name: String) -> void:
	if ally_radio.playing:
		return
	pass

func play_ally_radio(file_name: String) -> void:
	if ally_radio.playing:
		return
	pass