extends Sprite2D
class_name GameScrollingSprite

@export var move_speed := 0.0

var _initial_position := Vector2.ZERO
var _texture_size: Vector2 = Vector2.ZERO

func get_initial_position() -> Vector2:
    return _initial_position

func _ready():
    _texture_size = texture.get_size()
    _initial_position = position

func _process(_delta: float):
    var game_size := get_viewport_rect().size

    if _texture_size != Vector2.ZERO:
        position.x = wrapf(position.x, -_texture_size.x / 2, game_size.x + _texture_size.x / 2)
