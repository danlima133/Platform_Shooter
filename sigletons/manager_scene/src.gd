extends Node

signal load_scene_finished()

const LOADING_SCREEN = preload("res://sigletons/manager_scene/load_screen/load_screen.tscn")

const MAIN = "res://playtime/main.tscn"
var LEVELS_PATH = "res://playtime/levels/"

const MAIN_NAME = "main"

enum Envs {
	MAIN
	LEVEL
	GENERIC
	UNKNOW
}

onready var ROOT = get_tree().root

var _levels = {}
var _current_level = MAIN_NAME

var _env = Envs.UNKNOW

func _ready():
	_levels = _get_levels()
	_set_env(_try_get_current_env())

func _try_get_current_env():
	if ROOT.has_node(MAIN_NAME):
		return Envs.MAIN
	var _levels_name = _levels.keys()
	for _level_name in _levels_name:
		if ROOT.has_node(_level_name):
			return Envs.LEVEL
	var _scenes_in_root = ROOT.get_children()
	for _scene in _scenes_in_root:
		var _split_name = _scene.name.split("->")
		var _is_generic = _split_name[1] if _split_name.size() == 2 else ""
		if _is_generic == "generic":
			return Envs.GENERIC
	return Envs.UNKNOW

func _get_levels():
	var _dir = Directory.new()
	var _err = _dir.open(LEVELS_PATH)
	if _err == OK:
		_dir.list_dir_begin(true)
		var _file = _dir.get_next()
		var _levels = {}
		while _file != "":
			var _level_path = LEVELS_PATH + _file
			var _level_name = _file.split(".")[0]
			_levels[_level_name] = _level_path
			_file = _dir.get_next()
		return _levels
	return ERR_FILE_NOT_FOUND

func _remove_current_scene(scene_name):
	if ROOT.has_node(scene_name):
		ROOT.get_node(scene_name).queue_free()
		return OK
	return ERR_INVALID_DATA

func _set_scene_name(scene, scene_name, as_generic = false):
	if as_generic:
		scene.name = scene_name + "->generic"
	else: scene.name = scene_name

func _set_env(env):
	_env = env

func _load_scene(path):
	if ResourceLoader.exists(path):
		var _load_screen = LOADING_SCREEN.instance()
		var _loader = ResourceLoader.load_interactive(path)
		var _loading = _loader.poll()
		add_child(_load_screen)
		yield(get_tree().create_timer(1), "timeout")
		while _loading != ERR_FILE_EOF:
			_loading = _loader.poll()
			_load_screen.set_loading_percent(float(_loader.get_stage()) / _loader.get_stage_count() * 100)
			yield(get_tree().create_timer(0.1), "timeout")
		yield(_load_screen.__magic_on_load_complete(), "completed")
		emit_signal("load_scene_finished", _loader.get_resource())

func go_to_level(level_name, current_scene = _current_level):
	if _levels.has(level_name):
		var _err = _remove_current_scene(current_scene)
		if _err != OK: return ERR_CANT_RESOLVE
		var _level_path = _levels[level_name]
		_load_scene(_level_path)
		var _level = yield(self, "load_scene_finished").instance()
		_set_scene_name(_level, level_name)
		ROOT.add_child(_level)
		_set_env(Envs.LEVEL)
		_current_level = level_name
		return OK
	return ERR_INVALID_DATA

func go_to_main(current_scene = _current_level):
	var _err = _remove_current_scene(current_scene)
	if _err != OK: return ERR_INVALID_DATA
	_load_scene(MAIN)
	var _scene = yield(self, "load_scene_finished").instance()
	_set_scene_name(_scene, MAIN_NAME)
	ROOT.add_child(_scene)
	_set_env(Envs.MAIN)
	_current_level = MAIN_NAME
	return OK

func go_to_scene(scene_path, scene_name, current_scene):
	if ResourceLoader.exists(scene_path):
		var _err = _remove_current_scene(current_scene)
		if _err == OK:
			var _scene = yield(self._load_scene(scene_path), "completed").instance()
			_set_scene_name(_scene, scene_name, true)
			ROOT.add_child(_scene)
			_set_env(Envs.GENERIC)
			_current_level = _scene.name
			return OK
		return ERR_CANT_RESOLVE
	return ERR_FILE_BAD_PATH

func reload_current_scene(scene = _current_level):
	if ROOT.has_node(scene):
		var _current_scene = ROOT.get_node(scene)
		var _instance_path = _current_scene.filename
		_load_scene(_instance_path)
		var _scene = yield(self, "load_scene_finished").instance()
		_scene.name = _current_scene.name
		_current_scene.queue_free()
		yield(get_tree(), "idle_frame")
		ROOT.add_child(_scene)

func get_env():
	return _env

func get_current_scene():
	return _current_level
