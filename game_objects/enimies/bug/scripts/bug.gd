extends Node2D

var vSignals = Modules.import("utils.signals.tools.vsignal.gd").get_data()

export(int) var velocity

onready var on_floor = $on_floor
onready var is_wall = $is_wall

var _dir = Vector2.ZERO
var _side = 1

func _physics_process(delta):
	if not _on_floor() or _is_wall():
		if _side == 1:
			_side = -1
		else:
			_side = 1
	_dir.x = _side * velocity
	scale.x = _side
	translate(_dir * delta)

func _on_floor():
	return on_floor.is_colliding()

func _is_wall():
	return is_wall.is_colliding()

func _on_hurt_box_at_hurt_factor():
	vSignals.emmit_vsignal("enemy_death")
	queue_free()
