extends Control
class_name GameTouchInput

var touch_idx := -1
var touch_position := Vector2.ZERO

func _unhandled_input(event: InputEvent):
    if event is InputEventScreenTouch:
        if event.pressed && touch_idx == -1:
            touch_idx = event.index
            touch_position = event.position

        elif !event.pressed && event.index == touch_idx:
            touch_idx = -1
            touch_position = Vector2.ZERO

            Input.action_release("game_brake")
            Input.action_release("game_accelerate")

func _process(_delta: float) -> void:
    var game_size := get_viewport_rect().size

    if touch_idx >= 0:
        if touch_position.x > game_size.x / 2:
            Input.action_press("game_accelerate")
        elif touch_position.x < game_size.x / 2:
            Input.action_press("game_brake")
