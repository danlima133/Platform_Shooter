extends Node2D

const _animations = ["player_move_1", "player_move_2"]

onready var anim = $anim
onready var timer = $anim/timer

func start_anim():
	var _idx = randi() % _animations.size() - 1
	var _animation_name = _animations[_idx]
	if anim.has_animation(_animation_name):
		anim.play(_animation_name)
		yield(anim, "animation_finished")

func _ready():
	_set_timer()

func _set_timer():
	timer.wait_time = rand_range(10, 20)
	timer.start()

func _on_timer_timeout():
	yield(start_anim(), "completed")
	_set_timer()
