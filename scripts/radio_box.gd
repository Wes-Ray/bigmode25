extends Node3D

@onready var ally_radio :AudioStreamPlayer3D= %AllyRadio
@onready var enemy_radio :AudioStreamPlayer3D= %EnemyRadio

# Dictionary ctrl+v generated from util/prep_voice_dicts.ps1
@onready var enemy_voices := {
	"1st blast door": preload("res://assets/voicelines/enemy/1st blast door.ogg"),
	"another blast door": preload("res://assets/voicelines/enemy/another blast door.ogg"),
	"can you hit anything": preload("res://assets/voicelines/enemy/can you hit anything.ogg"),
	"DIE SCUM": preload("res://assets/voicelines/enemy/DIE SCUM.ogg"),
	"he wont live through the explosion": preload("res://assets/voicelines/enemy/he wont live through the explosion.ogg"),
	"he wont survive the generator room": preload("res://assets/voicelines/enemy/he wont survive the generator room.ogg"),
	"Hes going for the cystals": preload("res://assets/voicelines/enemy/Hes going for the cystals.ogg"),        
	"hes too fast": preload("res://assets/voicelines/enemy/hes too fast.ogg"),
	"Ill do it myself": preload("res://assets/voicelines/enemy/Ill do it myself.ogg"),
	"look alive": preload("res://assets/voicelines/enemy/look alive.ogg"),
	"motion detected": preload("res://assets/voicelines/enemy/motion detected.ogg"),
	"somebody stop this guy": preload("res://assets/voicelines/enemy/somebody stop this guy.ogg"),
	"stations coming down": preload("res://assets/voicelines/enemy/stations coming down.ogg"),
	"try to survive this": preload("res://assets/voicelines/enemy/try to survive this.ogg"),
	"what the hell was that": preload("res://assets/voicelines/enemy/what the hell was that.ogg"),
}
@onready var ally_voices := {
	"comeon1_redleader": preload("res://assets/voicelines/ally/comeon1_redleader.ogg"),
	"comeon2_redleader": preload("res://assets/voicelines/ally/comeon2_redleader.ogg"),
	"comeon3_redleader": preload("res://assets/voicelines/ally/comeon3_redleader.ogg"),
	"core meltdown": preload("res://assets/voicelines/ally/core meltdown.ogg"),
	"death1_redleader": preload("res://assets/voicelines/ally/death1_redleader.ogg"),
	"death2_redleader": preload("res://assets/voicelines/ally/death2_redleader.ogg"),
	"death3_redleader": preload("res://assets/voicelines/ally/death3_redleader.ogg"),
	"doorshut1_redleader": preload("res://assets/voicelines/ally/doorshut1_redleader.ogg"),
	"entering1_redleader": preload("res://assets/voicelines/ally/entering1_redleader.ogg"),
	"entering2_redleader": preload("res://assets/voicelines/ally/entering2_redleader.ogg"),
	"entering3_redleader": preload("res://assets/voicelines/ally/entering3_redleader.ogg"),
	"escaping1_redleader": preload("res://assets/voicelines/ally/escaping1_redleader.ogg"),
	"exiting1_redleader": preload("res://assets/voicelines/ally/exiting1_redleader.ogg"),
	"exiting2_redleader": preload("res://assets/voicelines/ally/exiting2_redleader.ogg"),
	"firstgate1_redleader": preload("res://assets/voicelines/ally/firstgate1_redleader.ogg"),
	"firstgate2_redleader": preload("res://assets/voicelines/ally/firstgate2_redleader.ogg"),
	"firstgate3_redleader": preload("res://assets/voicelines/ally/firstgate3_redleader.ogg"),
	"firstgate4_readleader": preload("res://assets/voicelines/ally/firstgate4_readleader.ogg"),
	"intro1_readleader": preload("res://assets/voicelines/ally/intro1_readleader.ogg"),
	"intro2_readleader": preload("res://assets/voicelines/ally/intro2_readleader.ogg"),
	"midway 1_redleader": preload("res://assets/voicelines/ally/midway 1_redleader.ogg"),
	"move it prism one": preload("res://assets/voicelines/ally/move it prism one.ogg"),
	"toohigh1_redleader": preload("res://assets/voicelines/ally/toohigh1_redleader.ogg"),
}

# func _ready() -> void:
# 	print("ENEMY VOICES")
# 	print(enemy_voices)
# 	print("ALLY VOICES")
# 	print(ally_voices)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		print("DEBUG VOICE")
		_play_radio(ally_radio, "comeon1_redleader", ally_voices)
	if Input.is_action_just_pressed("debug2"):
		print("DEBUG VOICE")
		_play_radio(ally_radio, "move it prism one", ally_voices)
	if Input.is_action_just_pressed("debug3"):
		print("DEBUG VOICE")
		_play_radio(enemy_radio, "1st blast door", enemy_voices)

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
