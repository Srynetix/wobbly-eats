extends Control
class_name GameFallingPackages

@export var package_count := 50 : set = _set_package_count
@export var package_scale_min := 0.25
@export var package_scale_max := 0.75
@export var package_fall_speed_min := 50.0
@export var package_fall_speed_max := 150.0
@export var package_rotation_degrees_speed_min := 15.0
@export var package_rotation_degrees_speed_max := 90.0
@export var package_random_color := false

class FallingPackage:
    extends Sprite2D

    var package_fall_speed := 0.0
    var package_rotation_degrees_speed := 0.0
    var package_color := Color.WHITE

    func _init(package_scale: float, fall_speed: float, rotation_degrees_speed: float, package_color_: Color) -> void:
        texture = GameLoadCache.load_resource("PackageTexture")
        modulate = package_color
        package_fall_speed = fall_speed
        package_rotation_degrees_speed = rotation_degrees_speed
        package_color = package_color_
        scale = Vector2.ONE * package_scale

    func _ready() -> void:
        var game_size := get_viewport_rect().size
        position.x = randf_range(0, game_size.x)
        position.y = randf_range(0, game_size.y)
        modulate = package_color

    func _process(delta: float) -> void:
        var game_size := get_viewport_rect().size

        position.y += package_fall_speed * delta
        rotation_degrees += package_rotation_degrees_speed * delta

        var package_size = texture.get_size() * scale
        if position.y - package_size.y / 2 > game_size.y:
            position.y = -package_size.y / 2

func _ready() -> void:
    _generate_sprites()

func _generate_sprites() -> void:
    var packages := []

    for count in package_count:
        var package_scale = randf_range(package_scale_min, package_scale_max)
        var package_fall_speed = randf_range(package_fall_speed_min, package_fall_speed_max)
        var package_rotation_degrees_speed = randf_range(package_rotation_degrees_speed_min, package_rotation_degrees_speed_max)
        var package_sprite := FallingPackage.new(
            package_scale,
            package_fall_speed,
            package_rotation_degrees_speed,
            SxColor.rand() if package_random_color else Color.WHITE
        )
        packages.push_back(package_sprite)

    packages.sort_custom(func(a, b): return a.scale.x < b.scale.x)

    for package in packages:
        add_child(package)

func _set_package_count(value: int) -> void:
    package_count = value

    for child in get_children():
        child.queue_free()

    _generate_sprites()
