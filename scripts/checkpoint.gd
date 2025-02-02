extends Node

var current_checkpoint := id.START

enum id {
    START,
    ENTERING_CANYON,
    FAST_SHOOT_TURRETS,
    BEFORE_CHASE,
}