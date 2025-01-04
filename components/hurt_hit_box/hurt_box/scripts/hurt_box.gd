extends Box
class_name HurtBox

signal hurt(hurt_box, hit_box)
signal at_hurt_factor()

export(int) var _hurt
export(int) var _hurt_factor

var _hurt_max = _hurt
var _in_hurt_factor = false

func _ready():
	_hurt_max = _hurt

func _on_enter_box(box_collision):
	if _hurt > _hurt_factor:
		var _hit = box_collision.get_hit()
		_damage(_hit)
		emit_signal("hurt", self, box_collision)

func _on_exit_box(box_exited):
	pass

func _damage(damage):
	_hurt -= damage
	if _hurt <= _hurt_factor:
		if not _in_hurt_factor:
			emit_signal("at_hurt_factor")
			_in_hurt_factor = true

func kill():
	var _damage = _hurt_max - _hurt_factor
	_damage(_damage)

func set_hurt(hurt):
	_hurt = hurt

func get_hurt():
	return _hurt

func get_hurt_max():
	return _hurt_max

func update_hurt_max():
	_hurt_max = _hurt

func in_hurt_factor():
	return _in_hurt_factor
