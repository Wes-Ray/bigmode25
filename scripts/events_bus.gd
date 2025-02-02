extends Node

signal game_reset
signal rocket_count_changed(rockets: int)

# use ZoneNames.id
signal player_entered_zone_trigger(zone_name: int)

signal ceiling_warning_started()
signal ceiling_warning_stopped()

signal player_objective_complete_trigger(zone_name: int)

signal player_failed_chase
