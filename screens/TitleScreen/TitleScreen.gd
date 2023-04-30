extends Control

@onready var _falling_packages := %FallingPackages as GameFallingPackages
@onready var _play_btn := %Play as Button
@onready var _levels_btn := %Levels as Button
@onready var _levels_selection := %LevelSelection as VBoxContainer
@onready var _quit_btn := %Quit as Button
@onready var _main_menu := %MainMenu as VBoxContainer
@onready var _level_selection_section := %LevelSelectionSection as Control
@onready var _level_selection_scroll := %Scroll as ScrollContainer
@onready var _go_back_btn := %GoBack as SxFaButton
@onready var _clear_data_btn := %ClearDataBtn as Button
@onready var _clear_data_dlg := $ClearDataDialog as SxFullScreenConfirmationDialog
@onready var _title := %Title as RichTextLabel

func _ready() -> void:
    if GameData.game_finished:
        GameMusicPlayer.fade_in()
        GameMusicPlayer.play(34.0)
        _falling_packages.package_count = 50

    _play_btn.pressed.connect(_fade_to_game_screen)
    _quit_btn.pressed.connect(_quit_game)
    _levels_btn.pressed.connect(_show_levels)
    _go_back_btn.pressed.connect(_go_back_to_menu)
    _clear_data_btn.pressed.connect(_open_clear_data_dialog)
    _clear_data_dlg.confirmed.connect(_clear_data)
    _clear_data_dlg.canceled.connect(_go_back_to_menu)
    _title.meta_clicked.connect(_on_meta_clicked)
    _play_btn.grab_focus()

    _build_level_selection()

func _on_meta_clicked(url: String) -> void:
    OS.shell_open(url)

func _show_levels() -> void:
    _main_menu.visible = false
    _level_selection_section.visible = true
    _levels_selection.find_next_valid_focus().grab_focus()

func _go_back_to_menu() -> void:
    _main_menu.visible = true
    _level_selection_section.visible = false
    _play_btn.grab_focus()

func _build_level_selection() -> void:
    # Add margin
    var margin_top := Control.new()
    margin_top.custom_minimum_size = Vector2(0, 16)
    _levels_selection.add_child(margin_top)

    for x in range(1, min(GameData.get_level_count(), GameData.max_level) + 1):
        var data := GameData.get_level_data(x)
        var entry := _build_level_entry(x, data)
        _levels_selection.add_child(entry)

    # Add margin
    var margin_bottom := Control.new()
    margin_bottom.custom_minimum_size = Vector2(0, 16)
    _levels_selection.add_child(margin_bottom)

func _run_level(level_id: int) -> void:
    GameData.current_level = level_id
    _fade_to_game_screen()

func _show_score(best_time: Array) -> String:
    var score = "%s - %0.2f" % [best_time[0], float(best_time[1])]
    if best_time[0] == "YOU":
        score = "[color=yellow]%s[/color]" % score
    return score

func _build_level_entry(level_id: int, data: GameData.LevelData) -> HBoxContainer:
    var level_name_btn := Button.new()
    level_name_btn.custom_minimum_size = Vector2(256, 64)
    level_name_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    level_name_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    level_name_btn.text = "Level %d" % int(level_id)
    level_name_btn.pressed.connect(_run_level.bind(level_id))
    level_name_btn.add_theme_font_override("font", GameLoadCache.load_resource("Font"))
    level_name_btn.add_theme_font_size_override("font_size", 32)

    var score_rtl := RichTextLabel.new()
    score_rtl.add_theme_font_override("normal_font", GameLoadCache.load_resource("Font"))
    score_rtl.add_theme_font_size_override("normal_font_size", 24)
    score_rtl.add_theme_constant_override("outline_size", 4)
    score_rtl.add_theme_color_override("font_outline_color", Color.BLACK)
    score_rtl.fit_content = true
    score_rtl.custom_minimum_size = Vector2(256, 32)
    score_rtl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    score_rtl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    score_rtl.bbcode_enabled = true
    score_rtl.text = "[center]1. %s\n2. %s\n3. %s[/center]" % [
        _show_score(data.best_times[0]),
        _show_score(data.best_times[1]),
        _show_score(data.best_times[2]),
    ]

    var scores := VBoxContainer.new()
    scores.add_child(score_rtl)

    var entry_container := HBoxContainer.new()
    entry_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    entry_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    entry_container.add_child(level_name_btn)
    entry_container.add_child(scores)

    return entry_container

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _level_selection_scroll.scroll_vertical -= 16
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _level_selection_scroll.scroll_vertical += 16

func _fade_to_game_screen() -> void:
    set_process_input(false)
    GameMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")

func _quit_game() -> void:
    get_tree().quit()

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed && event.keycode == KEY_ESCAPE:
            if _go_back_btn.is_visible_in_tree():
                _go_back_to_menu()

func _open_clear_data_dialog() -> void:
    _clear_data_dlg.show_dialog()

func _clear_data() -> void:
    GameData.reset_data()
    GameMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "BootScreen")
