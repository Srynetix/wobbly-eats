extends Node2D

@onready var _path := $Path2D as Path2D
@onready var _body := $StaticBody2D as StaticBody2D

func _ready() -> void:
    var polygon := _path.curve.tessellate()
    var collision_poly := CollisionPolygon2D.new()
    collision_poly.polygon = polygon
    _body.add_child(collision_poly)
