extends AudioStreamPlayer

var _initial_volume := 0.0

var muted := false : set = _set_muted

func _ready() -> void:
    _initial_volume = volume_db

func _set_muted(value: bool) -> void:
    muted = value
    if muted:
        volume_db = linear_to_db(0)
    else:
        volume_db = _initial_volume

func fade_in(speed: float = 1.0) -> void:
    volume_db = -80
    var tween = get_tree().create_tween()
    tween.tween_property(self, "volume_db", _initial_volume, speed).from(-80)
    await tween.finished

func fade_out(speed: float = 1.0) -> void:
    var tween = get_tree().create_tween()
    tween.tween_property(self, "volume_db", -80, speed)
    await tween.finished
    stop()
