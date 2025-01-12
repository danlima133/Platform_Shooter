extends CanvasLayer

var vSignals = Modules.import("utils.signals.tools.vsignal.gd").get_data()
var Groups = Modules.import("groups.tools.index.gd").get_data()

onready var bullets_container = $control/Control/player_bullets
onready var game_over = $game_over
onready var life_container = $control/Control/player_life/life_container
onready var root = $control
onready var enimies = $control/Control/enimies_in_level/HBoxContainer2/enimies
onready var max_enimies = $control/Control/enimies_in_level/HBoxContainer2/max_enimies
onready var player_win = $player_win
onready var level_time = $control/Control/level_timer/conatainer/time
onready var conslusion_time = $player_win/CenterContainer/VBoxContainer/padding/VBoxContainer/conslusion_time
onready var game_pause = $game_pause


const bullet_texture = preload("res://assets/textures/altas/generic/player_bullet.tres")
const life_texture = preload("res://assets/ui/bar_shadow_round_outline_small_square.png")

var _bullets:Array
var _life:Array
var _can_pause = true

var _next_level = ""

var _vgroup_level_timer = null
var _level_timer = null

class Component extends TextureRect:
	var active = true
	
	func set_texture(image):
		texture = image
	
	func active():
		var _anim = get_tree().create_tween()
		_anim.tween_property(self, "modulate:a", 1, 0.15)
		_anim.play()
		active = true
	
	func desactive():
		var _anim = get_tree().create_tween()
		_anim.tween_property(self, "modulate:a", 0.5, 0.15)
		_anim.play()
		active = false

class LifeComponent extends Component:
	const LIFE_FULL_TEXTURE = preload("res://assets/ui/bar_round_small_square.png")
	
	var _life = TextureRect.new()
	
	func _ready():
		_set_texture_rect(self)
		_life.texture = LIFE_FULL_TEXTURE
		_set_texture_rect(_life)
		add_child(_life)
	
	func _set_texture_rect(texture_rect):
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.rect_min_size = Vector2(8, 16)
	
	func active():
		var _anim = get_tree().create_tween()
		_anim.tween_property(_life, "modulate:a", 1, 0.15)
		_anim.play()
		active = true
	
	func desactive():
		var _anim = get_tree().create_tween()
		_anim.tween_property(_life, "modulate:a", 0, 0.15)
		_anim.play()
		active = false

#func ref
func _set_state_component(state, components, invert = false):
	var _indexs = []
	if invert: _indexs = range(components.size() - 1, 0, -1)
	else: _indexs = range(components.size())
	for _index in _indexs:
		var _component = components[_index]
		if _component.active != state:
			if state:
				_component.active()
			else:
				_component.desactive()
			return _component

func _ready():
	game_over.hide()
	player_win.hide()
	disable_bullet_container()
	vSignals.connect_vsignal("player_game_over", self, "_on_player_dethe")
	vSignals.connect_vsignal("player_win", self, "_on_player_win")
	_vgroup_level_timer = Groups.create_virtual_group("level_timer")
	if _vgroup_level_timer.has_vmember("level_timer"):
		_level_timer = _vgroup_level_timer.get_vmember("level_timer")

func _input(event):
	if Input.is_action_just_pressed("game_pause") and _can_pause:
		game_pause.show()
		get_tree().paused = true

func _process(delta):
	if _level_timer:
		level_time.text = \
		"%s:%s" % [_level_timer.get_minutes(0), _level_timer.get_seconds(0)]

func _set_bullet(state):
	var _funcref = funcref(self, "_set_state_component")
	return _funcref.call_funcv([state, _bullets])

func set_life(state):
	var _funcref = funcref(self, "_set_state_component")
	return _funcref.call_funcv([state, _life, true])

func enable_bullet_container():
	bullets_container.show()
	var anim = get_tree().create_tween()
	anim.tween_property(bullets_container, "modulate:a", 1, 0.25)
	anim.play()

func disable_bullet_container():
	var anim = get_tree().create_tween()
	anim.tween_property(bullets_container, "modulate:a", 0, 0.25)
	anim.play()
	yield(anim, "finished")
	bullets_container.hide()
	
func create_bullets(count):
	for index in range(count):
		var bullet = Component.new()
		bullet.set_texture(bullet_texture)
		bullets_container.add_child(bullet)
		_bullets.append(bullet)
		bullet.active()
	bullets_container.rect_global_position.y = (174 - (_bullets.size() * 11))

func create_life(count):
	for index in range(count):
		var life = LifeComponent.new()
		life.set_texture(life_texture)
		life_container.add_child(life)
		_life.append(life)
		life.active()

func set_enimies_in_level(enimies, enimies_max):
	self.enimies.text = str(enimies)
	max_enimies.text = str(enimies_max)

func show_hud(anim = true):
	if anim:
		$"%anim".play_backwards("fade")
	else:
		root.modulate.a = 1

func hide_hud(anim = true):
	if anim:
		$"%anim".play("fade")
	else:
		root.modulate.a = 0

func _on_player_dethe(args):
	hide_hud()
	game_over.show()

func _on_player_win(args):
	_next_level = args[0]
	if _next_level.empty():
		$"%next_level_btn".disabled = true
	hide_hud()
	player_win.show()
	_level_timer.stop()
	conslusion_time.text = \
	"Time %s:%s" % [_level_timer.get_minutes(0), _level_timer.get_seconds(0)]

func _on_restart_level_btn_pressed():
	ManagerScenes.reload_current_scene()

func _on_next_level_btn_pressed():
	ManagerScenes.go_to_level(_next_level, ManagerScenes.get_current_scene())

func _on_resume_btn_pressed():
	game_pause.hide()
	get_tree().paused = false

func _on_main_btn_pressed():
	get_tree().paused = false
	ManagerScenes.go_to_main()


