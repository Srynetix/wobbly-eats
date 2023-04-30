extends Control

@onready var _overlay := $Overlay as ColorRect

func _ready() -> void:
    await GameSceneTransitioner.fade_in()

    var tween := get_tree().create_tween()
    tween.tween_property(_overlay, "color", SxColor.with_alpha_f(Color.BLACK, 0.0), 5.0).from(Color.BLACK)

    await tween.finished
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "IntroScreen")
