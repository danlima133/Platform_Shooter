extends CanvasLayer

onready var loading_bar = $load_screen/PanelContainer/padding/VBoxContainer/loading_bar
onready var player_laoding = $load_screen/PanelContainer/padding/VBoxContainer/loading_bar/Node2D
onready var percent_label = $load_screen/PanelContainer/padding/VBoxContainer/percent

var _loading_percent:float = 0

func _process(delta):
	_update_loading_bar()

func _update_loading_bar():
	_loading_percent = clamp(_loading_percent, 0, 100)
	
	$"%load_effect".interpolate_property(player_laoding, "position:x", player_laoding.position.x, _calc_percent_by_width(_loading_percent, loading_bar.rect_size.x), 0.3)
	$"%load_effect".interpolate_property(loading_bar, "value", loading_bar.value, (float(_loading_percent) / 100) * 100, .3)
	$"%load_effect".start()
	percent_label.text = str(_loading_percent).pad_decimals(2) + "%"
	
func _calc_percent_by_width(percent, width):
	return (percent * width) / 100

func _calc_value_to_percet(value, max_value):
	return (value / max_value) * 100

func set_loading_percent(percent):
	_loading_percent = percent

func __magic_on_start_load():
	pass

func __magic_on_load_complete():
	set_loading_percent(100)
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()
