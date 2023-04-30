extends Line2D
class_name GameTrail

@export var length := 50

var _point = Vector2.ZERO
var _initial_position := Vector2.ZERO
var _initial_rotation := 0

func _ready() -> void:
    _initial_position = Vector2.ZERO
    _initial_rotation = 0

func _process(_delta: float) -> void:
    global_position = _initial_position
    global_rotation = _initial_rotation

    _point = get_parent().global_position

    add_point(_point)
    while get_point_count() > length:
        remove_point(0)
