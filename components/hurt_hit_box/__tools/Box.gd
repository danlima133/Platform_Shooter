extends Area2D
class_name Box

export(String) var _name
export(Array, String) var _filter

var _enable = true

func _ready():
	connect("area_entered", self, "_enter_box")
	connect("area_exited", self, "_exit_box")

func _enter_box(box_collision):
	if not _is_box_on_filter(box_collision): _on_enter_box(box_collision)

func _exit_box(box_exited):
	if not _is_box_on_filter(box_exited): _on_exit_box(box_exited)

func _on_enter_box(box_collision):
	assert(false, "Not Implemented")

func _on_exit_box(box_exited):
	assert(false, "Not Implemented")

func _is_box_on_filter(box):
	return box.get_name() in _filter

func get_name():
	return _name

func is_enable():
	return _enable

func enable():
	_enable = true
	for shape in get_children():
		shape.set_deferred("disabled", false)

func diasbled():
	_enable = false
	for shape in get_children():
		shape.set_deferred("disabled", true)
