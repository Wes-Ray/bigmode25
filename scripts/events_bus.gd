extends Node

signal game_reset
signal rocket_count_changed(rockets: int)

# use ZoneName.id
signal player_entered_zone_trigger(zone_name: int)

signal ceiling_warning_started()
signal ceiling_warning_stopped()
