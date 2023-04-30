@tool
extends Sprite2D
class_name GameRepeatingSprite

@export var scroll_speed := 0.0
@export var repetitions := 0
@export var initial_position := Vector2.ZERO

var _texture_size: Vector2 = Vector2.ZERO

func _ready():
    _texture_size = texture.get_size()
    if _texture_size != Vector2.ZERO:
        region_rect.position = Vector2.ZERO
        region_rect.size = Vector2(_texture_size.x * (repetitions + 1), _texture_size.y)
        region_enabled = true

func _process(delta: float):
    if _texture_size != Vector2.ZERO:
        region_rect.position.x = wrapf(region_rect.position.x + delta * -scroll_speed, 0, region_rect.size.x * 2)
        position = Vector2(initial_position.x + ((repetitions + 1) * _texture_size.x / 2), initial_position.y)
