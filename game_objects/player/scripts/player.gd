extends KinematicBody2D

var Groups = Modules.import("groups.tools.index.gd").get_data()
var vSignals = Modules.import("utils.signals.tools.vsignal.gd").get_data()

export(int) var velocity
export(int) var gravity
export(int) var jump
export(float) var friction

const SHOOT_POINT_OFFSET = Vector2(14, 3)
const ENEMYS = ["flyenemy", "bug"]

onready var texture = $texture
onready var bullets = $bullets
onready var shoot_point = $shoot_point
onready var shield = $shield
onready var check_on_top_enemy = $check_on_top_enemy

var _dir:Vector2
var _anim_move = true
var _gun = false
var _side = 1
var _double_jump = false
var _can_kill_enemy_jump = true
var _move = false

func _anim(anim):
	if _gun:
		return anim + "_gun"
	return anim

func _anim_gun(state, side):
	if state:
		return "active_gun_" + side
	return "desactive_gun_" + side

func _play_anim_change_gun(state):
	var _side = "left" if self._side > 0 else "right" 
	var _anim = _anim_gun(state, _side)
	_anim_move = false
	$"%anim".play(_anim)
	yield($"%anim", "animation_finished")
	_anim_move = true

func _play_anim_of_move(anim):
	if _anim_move:
		texture.play(anim)

func _kill():
	vSignals.emmit_vsignal("player_game_over")
	queue_free()

func _jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			_dir.y = -jump
			_double_jump = true
	elif _double_jump:
		if Input.is_action_just_pressed("jump"):
			_dir.y = -jump
			_double_jump = false
			$"%movement".play("double_jump")

func _ray_cast_colliding():
	for _ray_cast in check_on_top_enemy.get_children():
		if _ray_cast.is_colliding(): return _ray_cast.get_collider()

func _ready():
	set_can_move(_move)
	var _hud = Groups.get_node_in_group("HUDlevel")
	if _hud:
		_hud.create_life($"%hurt_box".get_hurt_max())

func _physics_process(delta):
	
	if Input.is_action_pressed("move_left"):
		_side = -1
		_dir.x = -velocity
		texture.flip_h = true
		_play_anim_of_move(_anim("run"))
		shoot_point.position = Vector2(-SHOOT_POINT_OFFSET.x, SHOOT_POINT_OFFSET.y)
	elif Input.is_action_pressed("move_right"):
		_side = 1
		_dir.x = velocity
		texture.flip_h = false
		_play_anim_of_move(_anim("run"))
		shoot_point.position = Vector2(SHOOT_POINT_OFFSET.x, SHOOT_POINT_OFFSET.y)
	else:
		_dir.x = lerp(_dir.x, 0, friction)
		_play_anim_of_move(_anim("idle"))
	
	_jump()
	
	if not is_on_floor():
		_can_kill_enemy_jump = true
		_play_anim_of_move(_anim("jump"))
	elif is_on_floor():
		_can_kill_enemy_jump = false
	
	_dir.y += gravity
	
	if Input.is_action_just_pressed("get_gun"):
		_gun = !_gun
		var _hud = Groups.get_node_in_group("HUDlevel")
		if _hud:
			match _gun:
				true: _hud.enable_bullet_container()
				false: _hud.disable_bullet_container()
		_play_anim_change_gun(_gun)
	
	if _gun:
		if Input.is_action_just_pressed("shoot"):
			bullets.shoot(_side)
	
	if global_position.y > 320:
		_kill()
	
	if _can_kill_enemy_jump:
		if _ray_cast_colliding():
			var _collider = _ray_cast_colliding()
			if _collider:
				if _collider.get_name() in ENEMYS:
					$air.emitting = true
					_dir.y = -300
					_collider.kill()
					_can_kill_enemy_jump = false
	
	_dir = move_and_slide(_dir, Vector2.UP)

func set_can_move(value):
	_move = value
	set_physics_process(_move)

func _on_win_level():
	set_can_move(false)

func _on_player_entred_level():
	$"%cutscene".play("enter_level")
	yield($"%cutscene", "animation_finished")

func _on_hurt_box_at_hurt_factor():
	_kill()
	
func _on_hurt_box_hurt(hurt_box, hit_box):
	var _levelset = Groups.get_node_in_group("levelset")
	if _levelset:
		_levelset.get_camera().shake(0.25, 100)
	shield.start_shield(6)
	var _hud = Groups.get_node_in_group("HUDlevel")
	if _hud:
		_hud.set_life(false)
