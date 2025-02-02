extends Node
# class_name ZoneName

# Global just to define zone names to pass to the player

# WARNING, adding zone name back toward the beginning
# will iterate consecutive enums, affecting any current 
# zone name enums set in the editor
enum id {
    # MAIN ZONES
    NONE,
    SPAWN_CAVE,
    ENTERING_CAVE,
    ENTERING_CANYON,
    FIRST_CANYON_GATE,
    BEFORE_FAST_SHOOT_TURRETS,
    FAST_SHOOT_TURRETS,
    ENTERING_BOSS_AREA,
    ENTERING_FINAL_RUN,
    # ALLY VOICE LINE ZONES 
    COMMS_CHECK,
    REVIEWED_CONOP,
    JERRY_RIGGED,
    WEAPONS_FREE,
    GATE_CYCLING,
    THREAD_NEEDLE,
    CLEAN_INSERTION,
    DEFENSE_POWER_ON,
    MAIN_GENERATOR_TWO_KLICKS,
    FOUR_POWER_CRYSTALS,
    SHIELD_COLLAPSE,
    CORE_GOING_CRITICAL,
    MOVE_IT_PRISM,
    COME_ON_PRISM,
    T_MINUS_30, 
    OUTSTANDING_WORK,
    GATE_SEALED,
    TOO_HIGH,
    DEATH_VARIANT,
    # TUTORIALS
    TUT_BOOST,
    TUT_ROLL,
    TUT_SHOOT,
    TUT_POWER_MANAGEMENT,
    # GATE STUFF/END GAME
    FAILED_TO_CROSS_GATE_IN_TIME,
    PLAYER_REACH_END,
    # ENEMY VOICE LINES ZONES
    FIRST_DOOR,
    ANOTHER_DOOR,
    HIT_ANYTHING,
    DIE_SCUM,
    WONT_LIVE,
    SURVIVE_GENERATOR,
    GOING_FOR_CRYSTALS,
    TOO_FAST,
    DO_IT_MYSELF,
    LOOK_ALIVE,
    MOTION_DETECTED,
    STOP_THIS_GUY,
    STATION_COMING_DOWN,
    SURVIVE_THIS,
    HELL_WAS_THAT,
}
