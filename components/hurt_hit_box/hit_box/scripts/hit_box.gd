extends Box

signal hit(hit_box, hurt_box)

export(int) var _hit

func set_hit(hit):
	_hit = hit

func get_hit():
	return _hit

func _on_enter_box(box_collision):
	emit_signal("hit", self, box_collision)

func _on_exit_box(box_exited):
	pass
