extends StaticBody2D
class_name GameDestination

@onready var _bell_sound_fx := $BellSoundFX as AudioStreamPlayer2D

func ring() -> void:
    _bell_sound_fx.play()
