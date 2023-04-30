extends Node2D
class_name GameClient

@onready var _sprite := $Sprite as Sprite2D
@onready var _area := $Area2D as Area2D
@onready var _punch_sound_fx := $PunchSoundFX as AudioStreamPlayer2D

var _hit := false

func _ready() -> void:
    _area.body_entered.connect(_on_package_hit)

func get_size() -> Vector2:
    return _sprite.texture.get_size() * _sprite.scale

func _on_package_hit(body: PhysicsBody2D) -> void:
    if body is GamePackage:
        if !_hit:
            _hit = true
            _punch_sound_fx.play()
            _collapse_client()

func _collapse_client() -> void:
    var tween := get_tree().create_tween()
    tween.parallel().tween_property(_sprite, "rotation_degrees", 90, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(_sprite, "position", Vector2(0, get_size().y / 2), 0.5).as_relative().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
