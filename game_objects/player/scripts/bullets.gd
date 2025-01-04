extends Node

var Groups = Modules.import("groups.tools.index.gd").get_data()

const BULLET = preload("res://game_objects/player_bullet/objs/player_bullet.tscn")

onready var shoot_point = $"../shoot_point"
onready var effect_bullet = $"../effects/bullet"

export(int) var max_bullets

var _hud:Object

func _ready():
	effect_bullet.hide()
	_hud = Groups.get_node_in_group("HUDlevel")
	if _hud:
		_hud.create_bullets(max_bullets)

func shoot(side):
	if get_child_count() < max_bullets:
		_effect_bullet(side)
		var bullet = BULLET.instance()
		bullet._side = bullet.Sides.LEFT if side > 0 else bullet.Sides.RIGHT
		bullet.global_position = shoot_point.global_position
		add_child(bullet)
		if _hud:
			_hud._set_bullet(false)

func _effect_bullet(side):
	effect_bullet.flip_h = true if side < 0 else false
	effect_bullet.global_position = shoot_point.global_position
	effect_bullet.show()
	yield(get_tree().create_timer(0.15), "timeout")
	effect_bullet.hide()
