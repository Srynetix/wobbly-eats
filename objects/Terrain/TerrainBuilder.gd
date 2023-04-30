extends Path2D
class_name GameTerrainBuilder

var _first_point := Vector2.ZERO
var _last_point := Vector2.ZERO

func _ready() -> void:
    curve = Curve2D.new()

func push_operation_list(data: Array) -> void:
    for operation in data:
        push_array_operation(operation)

func push_array_operation(data: Array) -> Vector2:
    var opcode := data[0] as String
    match opcode:
        "init":
            return push_init()
        "absolute":
            var x := data[1] as float
            var y := data[2] as float
            return push_point_absolute(x, y)
        "relative":
            var x := data[1] as float
            var y := data[2] as float
            return push_point_relative(x, y)
        "relative_curve":
            var x := data[1] as float
            var y := data[2] as float
            var in_x := data[3] as float
            var in_y := data[4] as float
            var out_x := data[5] as float
            var out_y := data[6] as float
            return push_point_relative_with_curve(x, y, Vector2(in_x, in_y), Vector2(out_x, out_y))
        "flat":
            var distance := data[1] as float
            return push_flat(distance)
        "ramp":
            var angle := data[1] as float
            var distance := data[2] as float
            return push_ramp(angle, distance)
        "cone":
            var angle := data[1] as float
            var distance := data[2] as float
            return push_cone(angle, distance)
        "curved_ramp":
            var angle := data[1] as float
            var distance := data[2] as float
            return push_curved_ramp(angle, distance)
        "bump":
            var angle := data[1] as float
            var distance := data[2] as float
            return push_bump(angle, distance)
        var other:
            push_error("Unsupported opcode %s", other)
            return Vector2.ZERO

func push_point_absolute(x: float, y: float) -> Vector2:
    var new_point := Vector2(x, y)
    curve.add_point(new_point)
    _last_point = new_point
    return new_point

func push_point_relative(x: float, y: float) -> Vector2:
    var new_point := _last_point + Vector2(x, y)
    curve.add_point(new_point)
    _last_point = new_point
    return new_point

func push_point_relative_with_curve(x: float, y: float, control_in: Vector2, control_out: Vector2) -> Vector2:
    var new_point := _last_point + Vector2(x, y)
    curve.add_point(new_point, control_in, control_out)
    _last_point = new_point
    return new_point

func push_init() -> Vector2:
    var step := 64

    _first_point = push_point_relative(-step / 2.0, step)
    push_point_relative(0, -step * 4)
    push_point_relative(step / 2.0, 0)
    push_point_relative(0, step * 3)
    return push_point_relative(step * 2, 0)

func push_flat(distance: float) -> Vector2:
    return push_point_relative(distance, 0)

func push_ramp(angle_degrees: float, distance: float) -> Vector2:
    var pt := Vector2(distance, 0).rotated(deg_to_rad(-angle_degrees))
    return push_point_relative(pt.x, pt.y)

func push_cone(angle: float, distance: float) -> Vector2:
    push_ramp(angle, distance / 2)
    return push_ramp(-angle, distance / 2)

func push_curved_ramp(angle_degrees: float, distance: float) -> Vector2:
    var control_x = min(distance / 2.0, 100)
    var pt := Vector2(distance, 0).rotated(deg_to_rad(-angle_degrees))
    return push_point_relative_with_curve(pt.x, pt.y, Vector2(-control_x, 0), Vector2(control_x, 0))

func push_bump(angle: float, distance: float) -> Vector2:
    push_curved_ramp(angle, distance / 2)
    return push_ramp(-angle, distance / 2)

func push_closure() -> void:
    var point = Vector2(_last_point.x, _first_point.y)
    _last_point = point
    curve.add_point(point)

func build(target: StaticBody2D) -> void:
    var polygon_2d := Polygon2D.new()
    var collision_polygon := CollisionPolygon2D.new()

    var farthest_point := Vector2.ZERO
    var polygon_data := curve.tessellate()
    for idx in len(polygon_data):
        polygon_data[idx] *= scale
        if polygon_data[idx].x > farthest_point.x:
            farthest_point = Vector2(polygon_data[idx].x, polygon_data[idx].y)

    polygon_2d.polygon = polygon_data
    polygon_2d.color = Color.from_string("#e2d672ff", Color.WHITE)
    collision_polygon.polygon = polygon_data

    target.position = position
    target.add_child(collision_polygon)
    target.add_child(polygon_2d)

    var destination := GameLoadCache.instantiate_scene("Destination")
    destination.position = farthest_point + position - Vector2(0, 96)
    target.get_parent().add_child(destination)

func build_minimap(minimap: GameMinimap) -> void:
    var polygon_data := curve.tessellate()
    var distance := 0.0
    for idx in len(polygon_data):
        if polygon_data[idx].x > distance:
            distance = polygon_data[idx].x

    for idx in len(polygon_data):
        polygon_data[idx] /= Vector2(distance, distance)
        polygon_data[idx] *= Vector2(minimap.map_size, minimap.map_size)

    # Remove initial points
    polygon_data.remove_at(0)
    polygon_data.remove_at(0)
    polygon_data.remove_at(0)
    polygon_data.remove_at(0)

    # Remove end points
    polygon_data.remove_at(len(polygon_data) - 1)

    minimap.total_distance = distance
    minimap.set_path_points(polygon_data)
