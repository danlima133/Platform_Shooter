extends CanvasLayer

onready var anim = $anim

func set_data(title, subtitle):
	var _title = get_node("Control/level_info/VBoxContainer/title")
	var _subtitle = get_node("Control/level_info/VBoxContainer/MarginContainer/subtitle")
	_title.text = title
	_subtitle.text = subtitle

func start_initialize():
	anim.play("level_info")
	yield(anim, "animation_finished")
	queue_free()
