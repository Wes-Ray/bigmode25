extends HSlider


func _ready() -> void:
	value = GameConfig.music_volume


func _process(_delta: float) -> void:
	GameConfig.sfx_volume = value
	AudioServer.set_bus_volume_db(1, GameConfig.convert_percentage_to_decibels(value))