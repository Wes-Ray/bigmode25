extends Node

var debug_dict := {}

func log(debug_name: String, value: Variant = "") -> void:
	debug_dict[debug_name] = value

func get_speed() -> String:
	if not debug_dict.has("speed"):
		return "-1"
	
	var fmt_str :String= "[b]%0d[/b]" % (debug_dict["speed"] * 6.0)
	return fmt_str
