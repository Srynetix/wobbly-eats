extends RigidBody2D
class_name GameWheel

var forward_speed := 1.5
var brake_speed := 0.5
var speed_limit := 50.0

@export var has_traction := true
@export var show_trail := false

@onready var _trail := $TrailPosition/Trail as GameTrail

var _node_tracer: SxNodeTracer

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    if !has_traction:
        return

    if Input.is_action_pressed("game_accelerate"):
        state.angular_velocity += forward_speed

    if Input.is_action_pressed("game_brake"):
        state.angular_velocity -= brake_speed

    state.angular_velocity = clamp(state.angular_velocity, -speed_limit, speed_limit)

func get_speed() -> float:
    return angular_velocity

func _ready() -> void:
    _trail.length = 0
    _node_tracer = SxNodeTracer.new()
    add_child(_node_tracer)

func _process(_delta: float) -> void:
    var max_speed := 100
    var max_length := 50

    if show_trail:
        var speed := angular_velocity
        var trail_length := int(max_length * clamp(speed, 0, max_speed) / max_speed)
        _trail.length = trail_length

    _node_tracer.trace_parameter("Angular velocity", angular_velocity)
