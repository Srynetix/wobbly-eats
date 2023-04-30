extends Control
class_name GameMinimap

@export var map_size := 250
@export var total_distance := 0.0
@export var moto_current_distance := 0.0
@export var moto_rotation_degrees := 0.0
@export var package_current_distance := 0.0
@export var package_rotation_degrees := 0.0
@export var offset := Vector2(16, 48.0)
@export var package_offset := Vector2(-2.0, -4.0)
@export var show_package := true

@onready var _panel := $Panel as Panel
@onready var _path := $Path2D as Path2D
@onready var _moto_follow := $Path2D/Moto as PathFollow2D
@onready var _package_follow := $Path2D/Package as PathFollow2D
@onready var _line := $Line as Line2D
@onready var _moto_cursor := $MotoCursor as Sprite2D
@onready var _package_cursor := $PackageCursor as Sprite2D

func _ready() -> void:
    _line.position += offset
    _panel.custom_minimum_size = Vector2(map_size + 32, map_size / 4.0)

func set_path_points(points: PackedVector2Array) -> void:
    _line.points = points
    _path.curve = Curve2D.new()
    for point in points:
        _path.curve.add_point(point)

func _process(_delta: float) -> void:
    _moto_follow.progress_ratio = min(moto_current_distance / total_distance, 1)
    _moto_cursor.position = _moto_follow.position + offset + Vector2(0, -_line.width)
    _moto_cursor.rotation_degrees = moto_rotation_degrees

    _package_cursor.visible = show_package
    if show_package:
        _package_follow.progress_ratio = min(package_current_distance / total_distance, 1)
        _package_cursor.position = _package_follow.position + offset + Vector2(0, -_line.width) + package_offset
        _package_cursor.rotation_degrees = package_rotation_degrees
