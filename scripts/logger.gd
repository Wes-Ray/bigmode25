extends Node

var debug_dict := {}

func log(debug_name: String, value: Variant = "") -> void:
	debug_dict[debug_name] = value

func get_speed() -> String:
	if not debug_dict.has("speed"):
		return "-1"
	
	# var fmt_str: String = "[b]%03d[/b]" % (debug_dict["speed"] * 6.0)
	var fmt_str: String = "[b]%03d[/b]" % (debug_dict["speed"])
	return fmt_str

func get_health() -> int:
	if not debug_dict.has("health"):
		return -1
	return debug_dict["health"]
