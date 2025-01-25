extends Node

var debug_dict := {}

func log(debug_name: String, value: Variant = "") -> void:
	debug_dict[debug_name] = value

func get_speed() -> String:
	if not debug_dict.has("speed"):
		return "-1"
	
	var fmt_str :String= "%0d" % (debug_dict["speed"] * 11.0)
	return fmt_str
