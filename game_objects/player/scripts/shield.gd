extends Node

onready var shield_timer = $shield_timer
onready var check_on_top_enemy = $"../check_on_top_enemy"
onready var effect = $effect

var _shield = false

func start_shield(time):
	set_raycasts(false)
	shield_timer.wait_time = time
	shield_timer.start()
	_shield = true
	$"%hurt_box".diasbled()
	effect.play("shield")

func _on_shield_timer_timeout():
	set_raycasts(true)
	effect.stop(true)
	effect.play("RESET")
	_shield = false
	$"%hurt_box".enable()

func has_shield():
	return _shield

func set_raycasts(value):
	for _raycast in check_on_top_enemy.get_children():
		_raycast.enabled = value
