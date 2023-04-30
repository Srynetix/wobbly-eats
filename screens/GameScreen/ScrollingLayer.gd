extends Node2D
class_name GameScrollingLayer

@export var scroll_amount := 0.0

func _process(delta: float) -> void:
    for sprite in get_children():
        var scrolling_sprite := sprite as GameScrollingSprite
        scrolling_sprite.position.x = scrolling_sprite.get_initial_position().x + scroll_amount / 500.0 * scrolling_sprite.move_speed
