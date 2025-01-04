extends Node2D
tool

var vSignals = Modules.import("utils.signals.tools.vsignal.gd").get_data()
var Groups = Modules.import("groups.tools.index.gd").get_data()

class LevelCamera extends Camera2D:
	
	var _shake = false
	var _duration = 0
	var _force = 0
	var _timer = Timer.new()
	
	func _init(width, height):
		current = true
		limit_left = 0
		limit_right = width
		limit_top = -height
		limit_bottom = 180
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		drag_margin_left = 0.35
		drag_margin_left = 0.35
		drag_margin_top = 0.4
		
		_timer.one_shot = true
		_timer.connect("timeout", self, "_on_timer_finished")
		add_child(_timer)
	
	func _process(delta):
		if _shake:
			_shake(delta)
	
	func _shake(delta):
		var _x = rand_range(1, -1)
		var _y = rand_range(1, -1)
		offset = Vector2(_x, _y) * _force * delta
	
	func shake(duration, force):
		_duration = duration
		_force = force
		_shake = true
		_timer.wait_time = _duration
		_timer.start()
	
	func _on_timer_finished():
		_shake = false

const MIN_WIDTH = 320
const FACTOR_HEIGHT = 180

export(int) var width setget _set_width
export(int) var height setget _set_height
export(String) var _next_level
export(NodePath) var player
export(String) var level_title
export(String) var level_subtitle

var _camera = null

var _enimies = null
var _enimies_in_level = 0
var _current_enimies_in_level = 0

func get_player():
	return get_node_or_null(player)

func get_camera():
	return _camera

func _set_width(value):
	if value <= MIN_WIDTH:
		value = MIN_WIDTH
	width = value
	_set_size()

func _set_height(value):
	if height == 0:
		height = FACTOR_HEIGHT
	height = value
	_set_size()

func _set_size():
	update()

func _create_camera():
	var _camera = LevelCamera.new(width, height)
	return _camera

func _draw():
	if Engine.editor_hint:
		var _limit_level = Rect2(0, 180, width, -FACTOR_HEIGHT if height == 0 else -(FACTOR_HEIGHT + height))
		draw_rect(_limit_level, Color.red, false, 2)

func _ready():
	if has_node("start"):
		if get_player():
			get_player().global_position = get_node("start").global_position
	
	if has_node("enemies"):
		_enimies = get_node("enemies")
		_enimies_in_level = _enimies.get_child_count()
		var _hud = Groups.get_node_in_group("HUDlevel")
		if _hud:
			_hud.set_enimies_in_level(_enimies_in_level, _enimies_in_level)
		vSignals.connect_vsignal("enemy_death", self, "_on_enemy_deathe")
		if _enimies_in_level == 0: printerr("Sem inimigos no level")
	else: printerr("Sem inimigos no level")
	
	if not Engine.editor_hint:
		_camera = _create_camera()
		add_child(_camera)
	
	var _level_timer_virtual_group = Groups.create_virtual_group("level_timer")
	var _level_timer = _level_timer_virtual_group.get_vmember("level_timer")
	if _level_timer: _level_timer.stop()
	var _hud = Groups.get_node_in_group("HUDlevel")
	var _player = Groups.get_node_in_group("player")
	_player.set_can_move(false)
	if _hud: _hud.hide_hud(false)
	if has_node("level_initialize"):
		var _level_initialize = get_node("level_initialize")
		_level_initialize.set_data(level_title, level_subtitle)
		yield(_level_initialize.start_initialize(), "completed")
	if _player:
		yield(_player._on_player_entred_level(), "completed")
	if _hud: _hud.show_hud()
	if _level_timer: _level_timer.resume()
	_player.set_can_move(true)

func _process(delta):
	if not Engine.editor_hint:
		if get_player():
			_camera.global_position = get_player().global_position

func _on_enemy_deathe(args):
	_current_enimies_in_level = _enimies.get_child_count() - 1
	var _hud = Groups.get_node_in_group("HUDlevel")
	if _hud:
		_hud.set_enimies_in_level(_enimies_in_level, _current_enimies_in_level)
	if _current_enimies_in_level == 0:
		var _player = Groups.get_node_in_group("player")
		if _player:
			_player.set_can_move(false)
		vSignals.emmit_vsignal("player_win", [_next_level])
