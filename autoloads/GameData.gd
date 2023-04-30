extends SxGameData

class LevelData:
    extends Object

    var best_times: Array
    var terrain_data: Array

    func _init(terrain_data_: Array, best_times_: Array):
        terrain_data = terrain_data_
        best_times = best_times_

var levels_data: Dictionary
var current_level := 1
var max_level := 1
var game_finished := false : set = _set_game_finished
var player_scores: Dictionary

func _ready() -> void:
    SxLog.set_max_log_level("SxGameData", SxLog.LogLevel.DEBUG)

    default_file_path = "user://ld53_save.dat"
    load_from_disk()

    levels_data = SxJson.read_json_file("res://data/levels.json")
    player_scores = load_value("player_scores", Dictionary())
    current_level = load_value("current_level", 1)
    max_level = load_value("max_level", 1)
    game_finished = load_value("game_finished", false)

func get_level_count() -> int:
    return len(levels_data["levels"])

func _merge_best_times(level_id: String, best_times: Array) -> Array:
    var new_best_times = Array()
    var player_time = player_scores.get(level_id)
    if player_time:
        var inserted := false
        for time in best_times:
            var what = time[1]
            if !inserted && float(player_time) < float(what):
                new_best_times.push_back(["YOU", player_time])
                new_best_times.push_back(time)
                inserted = true
            else:
                new_best_times.push_back(time)

    if len(new_best_times) == 4:
        new_best_times.pop_back()

    return new_best_times

func get_level_data(level_id: int) -> LevelData:
    var level_id_str = str(level_id)
    if level_id_str in levels_data["levels"]:
        return LevelData.new(
            levels_data["levels"][level_id_str]["terrain"],
            _merge_best_times(level_id_str, levels_data["levels"][level_id_str]["best_times"])
        )
    else:
        push_error("Unknown level %d" % level_id)
        return null

func _set_current_level(level: int) -> void:
    current_level = min(level, len(levels_data["levels"]))
    max_level = max(max_level, current_level)
    store_value("current_level", current_level)
    store_value("max_level", max_level)
    persist_to_disk()

func advance_level() -> void:
    _set_current_level(current_level + 1)

func _set_game_finished(value: bool) -> void:
    game_finished = value
    store_value("game_finished", value)
    persist_to_disk()

func set_player_score_for_level(level: int, score: float) -> void:
    var existing_score = player_scores.get(level)
    if (existing_score && float(score) < float(existing_score)) || !existing_score:
        player_scores[str(level)] = score
        store_value("player_scores", player_scores)
        persist_to_disk()

func reset_data() -> void:
    current_level = 1
    max_level = 1
    game_finished = false
    player_scores = {}
    store_value("player_scores", player_scores)
    persist_to_disk()
