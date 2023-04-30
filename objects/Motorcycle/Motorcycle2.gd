extends RigidBody2D
class_name GameMotorcycle

signal destination_reached

@onready var _front_sensor := $FrontSensor as Area2D
@onready var _back_wheel := $BackWheelJoint/Wheel as GameWheel
@onready var _front_wheel := $FrontWheelJoint/Wheel as GameWheel
@onready var _camera := $Camera2D as Camera2D
@onready var _engine_sound_fx := $EngineSoundFX as AudioStreamPlayer2D
@onready var _crash_sound_fx := $CrashSoundFX as AudioStreamPlayer2D

var _node_tracer: SxNodeTracer
var _previous_velocity := Vector2.ZERO
var _impact_velocity := Vector2.ZERO
var _initial_engine_volume := 0.0

func _ready() -> void:
    _front_sensor.body_entered.connect(_on_collision)
    _camera.limit_bottom = int(GameConstants.BOTTOM_GAME_LIMIT)
    _node_tracer = SxNodeTracer.new()
    add_child(_node_tracer)
    _initial_engine_volume = _engine_sound_fx.volume_db
    _engine_sound_fx.playing = true

func get_impact_velocity() -> Vector2:
    return _impact_velocity

func game_over() -> void:
    _front_wheel.freeze = true
    _back_wheel.freeze = true
    freeze = true

    _front_wheel.angular_velocity = 0

func _process(_delta: float) -> void:
    _node_tracer.trace_parameter("Velocity", linear_velocity)
    _previous_velocity = linear_velocity
    _engine_sound_fx.volume_db = min(linear_to_db(0.1 + abs(_front_wheel.get_speed() / _front_wheel.speed_limit)), _initial_engine_volume)
    _engine_sound_fx.pitch_scale = 1 + abs(_front_wheel.get_speed() / _front_wheel.speed_limit) * 2

func _on_collision(body: PhysicsBody2D) -> void:
    if body is GameDestination:
        _impact_velocity = _previous_velocity
        body.ring()

        _engine_sound_fx.stop()
        _crash_sound_fx.play()
        emit_signal(destination_reached.get_name())

        _back_wheel.has_traction = false
        _front_wheel.has_traction = false
        _front_sensor.get_node("CollisionShape2D").set_deferred("disabled", true)
