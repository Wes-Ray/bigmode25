extends Node3D

@onready var ally_radio :AudioStreamPlayer3D= %AllyRadio
@onready var enemy_radio :AudioStreamPlayer3D= %EnemyRadio

var enemy_voices := {}
var ally_voices := {}

func _ready() -> void:
	# load ally voice lines
	var dir = DirAccess.open("res://assets/voicelines/ally")
	assert(dir, "failed to load ally voice files")
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".ogg"):
			var path = "res://assets/voicelines/ally/" + file_name
			ally_voices[file_name.get_basename()] = load(path)
		file_name = dir.get_next()

	# load enemy voice lines
	dir = DirAccess.open("res://assets/voicelines/enemy")
	assert(dir, "failed to load enemy voice files")
	dir.list_dir_begin()
	file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".ogg"):
			var path = "res://assets/voicelines/enemy/" + file_name
			enemy_voices[file_name.get_basename()] = load(path)
		file_name = dir.get_next()
	
	print("ENEMY VOICES")
	print(enemy_voices)
	print("ALLY VOICES")
	print(ally_voices)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		print("DEBUG VOICE")
		_play_radio(ally_radio, "comeon1_redleader", ally_voices)

func play_enemy_radio(file_name: String) -> void:
	if ally_radio.playing or enemy_radio.playing:
		return
	_play_radio(enemy_radio, file_name, enemy_voices)

func play_ally_radio(file_name: String) -> void:
	# TODO: might want to override the current voice for ally only, 
	# or enqueue a new one (or just timer it)
	if ally_radio.playing:
		return
	# TODO: could just temp lower volume for enemy radio
	if enemy_radio.playing:
		enemy_radio.stop()
	_play_radio(ally_radio, file_name, ally_voices)

func _play_radio(radio: AudioStreamPlayer3D, file_name: String, lines: Dictionary) -> void:
	assert(lines.has(file_name), "could not find audio file: %s" % file_name)

	radio.stop()
	radio.stream = lines[file_name]
	radio.play()
