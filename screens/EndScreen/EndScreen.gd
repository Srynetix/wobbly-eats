extends Control

@onready var _overlay := $Overlay as ColorRect
@onready var _text := $MarginContainer/Text as SxFadingRichTextLabel
@onready var _skip_label := %SkipLabel as Label

var _will_fade := false

func _ready() -> void:
    var tween := create_tween()
    tween.tween_property(_overlay, "color", SxColor.with_alpha_f(Color.BLACK, 0), 20.0).from(Color.BLACK).set_delay(10.0)

    var skip_tween := create_tween()
    skip_tween.tween_property(_skip_label, "modulate", Color.WHITE, 1.0).from(Color.TRANSPARENT)
    skip_tween.tween_property(_skip_label, "modulate", Color.TRANSPARENT, 1.0).from(Color.WHITE)
    skip_tween.set_loops()

    await _text.shown
    _will_fade = true

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed && event.keycode == KEY_ENTER:
            _will_fade = true

    if event is InputEventScreenTouch:
        if event.pressed:
            _will_fade = true

func _process(_delta: float) -> void:
    if _will_fade:
        set_process_input(false)
        set_process(false)
        GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")
