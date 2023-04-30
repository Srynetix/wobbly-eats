extends Control
class_name GameScreen

@onready var _moto := $Motorcycle2 as GameMotorcycle
@onready var _package := $Package as GamePackage
@onready var _package_launch_meters_label := $HUDLayer/MarginContainer/PackageLaunchMeters as RichTextLabel
@onready var _elapsed_time_label := $HUDLayer/MarginContainer/Time as Label
@onready var _client := $Client as GameClient
@onready var _terrain := $Terrain as StaticBody2D
@onready var _terrain_builder := $TerrainBuilder as GameTerrainBuilder
@onready var _boo_sound_fx := $BooSoundFX as AudioStreamPlayer
@onready var _scrolling_layer := $BackgroundLayer/Scrolling as GameScrollingLayer
@onready var _reload_btn := %Reload as SxFaButton
@onready var _toggle_music_btn := %ToggleMusic as SxFaButton
@onready var _level_info_label := %LevelInfo as RichTextLabel
@onready var _go_back_btn := %GoBack as SxFaButton
@onready var _minimap := %Minimap as GameMinimap
@onready var _instructions_label := %Instructions as RichTextLabel

var _node_tracer: SxNodeTracer

var _package_launch_meters := 0 : set = _set_package_launch_meters
var _elapsed_time := 0.0 : set = _set_elapsed_time
var _package_launched := false
var _package_launched_position := Vector2.ZERO
var _package_launch_force := Vector2.ZERO

func _ready() -> void:
    # Play music
    if !GameMusicPlayer.playing:
        GameMusicPlayer.fade_in()
        GameMusicPlayer.play()

    _node_tracer = SxNodeTracer.new()
    add_child(_node_tracer)

    _moto.destination_reached.connect(_on_destination_reached)
    _package.ground_touched.connect(_on_fallen_package)
    _package.almost_delivered.connect(_on_package_almost_delivered)
    _package_launch_meters_label.modulate = Color.TRANSPARENT
    _reload_btn.pressed.connect(_reload_level)
    _toggle_music_btn.pressed.connect(_toggle_music)
    _go_back_btn.pressed.connect(_go_back)

    # Build terrain
    var level_data := GameData.get_level_data(GameData.current_level)
    _terrain_builder.push_operation_list(level_data.terrain_data)
    _terrain_builder.push_closure()
    _terrain_builder.build(_terrain)
    _terrain_builder.build_minimap(_minimap)

    _level_info_label.text = _level_info_label.text.replace("{0}", str(GameData.current_level))
    _level_info_label.text = _level_info_label.text.replace("{1}", _show_score(level_data.best_times[0]))
    _level_info_label.text = _level_info_label.text.replace("{2}", _show_score(level_data.best_times[1]))
    _level_info_label.text = _level_info_label.text.replace("{3}", _show_score(level_data.best_times[2]))

    _update_music_toggle()

    var tween = get_tree().create_tween()
    tween.tween_property(_level_info_label, "modulate", Color.TRANSPARENT, 1.0).set_delay(2.0)

    var tween2 = get_tree().create_tween()
    tween2.tween_property(_instructions_label, "modulate", Color.TRANSPARENT, 4.0).set_delay(6.0)

func _show_score(best_time: Array) -> String:
    var score = "%s - %0.2f" % [best_time[0], float(best_time[1])]
    if best_time[0] == "YOU":
        score = "[color=yellow]%s[/color]" % score
    return score

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed && event.keycode == KEY_ENTER:
            _reload_level()

func _update_music_toggle() -> void:
    if GameMusicPlayer.muted:
        _toggle_music_btn.icon_name = "volume-xmark"
    else:
        _toggle_music_btn.icon_name = "volume-high"

func _toggle_music() -> void:
    GameMusicPlayer.muted = !GameMusicPlayer.muted
    _update_music_toggle()

func _go_back() -> void:
    GameMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")

func _on_destination_reached() -> void:
    var impact_velocity := _moto.get_impact_velocity()
    var impulse := Vector2(impact_velocity.x, impact_velocity.x) / 10.0 * Vector2(0.5, -0.5)
    _package_launch_force = impulse
    _node_tracer.trace_parameter("Package launch force", _package_launch_force)

    _package.launch_into_space(impulse)
    _moto.get_node("Camera2D").enabled = false

    _package_launched = true
    _package_launched_position = _package.position

    var tween := get_tree().create_tween()
    tween.tween_property(_package_launch_meters_label, "modulate", Color.WHITE, 2).from(Color.TRANSPARENT)
    await tween.finished

func _reload_level() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen", 0.5)

func _on_fallen_package() -> void:
    _boo_sound_fx.play()
    _moto.game_over.call_deferred()

    await _boo_sound_fx.finished
    _reload_level()

func _set_package_launch_meters(value: int) -> void:
    _package_launch_meters = value
    _package_launch_meters_label.text = "[center]%dm[/center]" % _package_launch_meters

func _process(delta: float) -> void:
    if _package_launched:
        _package_launch_meters = int((_package.position.x - _package_launched_position.x) * 0.01)
    else:
        _elapsed_time += delta

    _minimap.moto_rotation_degrees = _moto.rotation_degrees
    _minimap.moto_current_distance = _moto.position.x
    _minimap.package_rotation_degrees = _package.rotation_degrees
    _minimap.package_current_distance = _package.position.x

    if _package_launched:
        _minimap.show_package = false
        _scrolling_layer.scroll_amount = _package.position.x
    else:
        _scrolling_layer.scroll_amount = _moto.position.x

func _on_package_almost_delivered() -> void:
    _show_client()

func _show_client() -> void:
    var game_size := get_viewport_rect().size
    var client_size := _client.get_size()
    var package_distance := 16

    var tween := get_tree().create_tween()
    tween.tween_property(
        _client,
        "position",
        Vector2(_package.position.x, game_size.y - GameConstants.GROUND_HEIGHT) + Vector2(
            package_distance + client_size.x / 2,
            -client_size.y / 2
        ),
        1
    ).from(
        Vector2(_package.position.x, game_size.y - GameConstants.GROUND_HEIGHT) + Vector2(
            game_size.x / 2,
            -client_size.y / 2
        )
    ).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
    await tween.finished

    _prepare_for_next_round()

func _prepare_for_next_round() -> void:
    GameData.set_player_score_for_level(GameData.current_level, _elapsed_time)
    await get_tree().create_timer(2.0).timeout

    if GameData.get_level_count() == GameData.current_level:
        GameData.game_finished = true
        GameMusicPlayer.fade_out()
        GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "EndScreen")
    else:
        GameData.advance_level()
        _reload_level()

func _set_elapsed_time(value: float) -> void:
    _elapsed_time = value

    var seconds = floor(_elapsed_time)
    var milliseconds = (_elapsed_time - floor(_elapsed_time)) * 100
    _elapsed_time_label.text = "%d\"%02d" % [seconds, milliseconds]
