extends RigidBody2D
class_name GamePackage

signal ground_touched
signal almost_delivered
signal delivered

enum FoodType {
    Kebab,
    Pizza,
    Tacos,
    Salad,
    Burger,
    Bug
}

@export var food_type: FoodType = FoodType.Tacos
@export var food_type_random := false

@onready var _trail := $Trail as GameTrail
@onready var _camera := $Camera2D as Camera2D
@onready var _collision_shape = $CollisionShape2D as CollisionShape2D
@onready var _sprite := $Sprite2D as Sprite2D
@onready var _food_type_label := $FoodType as Label
@onready var _food_phrase_label := $FoodPhrase as Label
@onready var _hit_sound_fx := $AudioStreamPlayer2D as AudioStreamPlayer2D

func _get_random_food_type() -> FoodType:
    match SxRand.range_i(0, 5):
        0:
            return FoodType.Kebab
        1:
            return FoodType.Pizza
        2:
            return FoodType.Tacos
        3:
            return FoodType.Salad
        4:
            return FoodType.Burger
        _:
            return FoodType.Bug

var _launched := false
var _almost_delivered := false
var _delivered := false
var _node_tracer: SxNodeTracer

func _ready() -> void:
    _node_tracer = SxNodeTracer.new()
    add_child(_node_tracer)

    if food_type_random:
        food_type = _get_random_food_type()

    _trail.length = 2
    _camera.limit_bottom = int(GameConstants.BOTTOM_GAME_LIMIT)
    body_entered.connect(_on_collision)

    _food_type_label.text = _get_food_name(food_type)
    _food_phrase_label.text = _get_food_phrase(food_type)

func launch_into_space(force: Vector2) -> void:
    _camera.enabled = true
    _trail.length = 50
    _launched = true

    set_collision_mask_value(GameConstants.MOTORCYCLE_PHYSICS_LAYER, false)
    set_collision_mask_value(GameConstants.DEFAULT_PHYSICS_LAYER, false)
    apply_central_impulse(force)
    angular_velocity = force.length() / 100.0

func get_size() -> Vector2:
    return _sprite.texture.get_size() * _sprite.scale

func _get_food_name(food_type: FoodType) -> String:
    match food_type:
        FoodType.Kebab:
            return "Kebab"
        FoodType.Pizza:
            return "Pizza"
        FoodType.Tacos:
            return "Tacos"
        FoodType.Salad:
            return "Salad"
        FoodType.Burger:
            return "Burger"
    return "Bug"

func _get_food_phrase(food_type: FoodType) -> String:
    match food_type:
        FoodType.Kebab:
            return "Hmmm!"
        FoodType.Pizza:
            return "Mamma mia!"
        FoodType.Tacos:
            return "Crunchy!"
        FoodType.Salad:
            return "Was'nt hungry!"
        FoodType.Burger:
            return "Classic!"
    return "Woops!"

func _on_collision(body: PhysicsBody2D) -> void:
    _hit_sound_fx.play()

    if body.is_in_group("ground"):
        set_deferred("freeze", true)
        _collision_shape.set_deferred("disabled", true)
        emit_signal(ground_touched.get_name())

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    var package_size = get_size()
    var max_y = GameConstants.BOTTOM_GAME_LIMIT - GameConstants.GROUND_HEIGHT - package_size.y / 2
    var min_linear_velocity := 15
    var min_linear_velocity_almost := 450

    if _launched && !_delivered:
        if abs(state.linear_velocity.x) < min_linear_velocity_almost && !_almost_delivered:
            emit_signal(almost_delivered.get_name())
            _almost_delivered = true

        if position.y >= max_y:
            if abs(state.linear_velocity.y) > min_linear_velocity:
                state.transform.origin.y = max_y
                state.linear_velocity = state.linear_velocity * Vector2(0.5, -0.6)
                state.angular_velocity += state.linear_velocity.length() / 100.0
                _hit_sound_fx.play()
            else:
                state.transform.origin.y = max_y
                state.linear_velocity = Vector2.ZERO
                state.angular_velocity = 0

                _delivered = true
                set_deferred("freeze", true)
                emit_signal(delivered.get_name())

                var tween := get_tree().create_tween()
                tween.tween_property(self, "rotation_degrees", 360, 0.1)


    _node_tracer.trace_parameter("Linear velocity", linear_velocity)
