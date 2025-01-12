extends VBoxContainer

signal click_button(id)

const COLOR_CLICK_BUTTON = Color(0.039216, 0.223529, 0.521569)
const COLOR_DEFAUL_BUTTON = Color(0.023529, 0.14902, 0.34902)

onready var anim = $guns/anim
onready var pivot_1 = $guns/pivot1
onready var pivot_2 = $guns/pivot2
onready var deley = $deley

var _buttons = []

var _current_button = null
var _can_click = false

func _get_buttons():
	var _buttons = []
	for _button in get_children():
		if _button is MarginContainer:
			if _button.get_child_count() > 0:
				_buttons.append(_button)
	return _buttons

func _input(event):
	if Input.is_action_just_pressed("click_button"):
		if _current_button and _can_click:
			yield(_on_click(_current_button), "completed")
			emit_signal("click_button", _current_button.name)

func _ready():
	_buttons = _get_buttons()
	
	for _button in _buttons:
		var _label = _button.get_child(0) as Label
		_label.connect("mouse_entered", self, "_on_mouse_entered_label", [_label])
		_label.connect("mouse_exited", self, "_on_mouse_exit_label", [_label])

func _on_mouse_entered_label(label):
	label.set("custom_colors/font_color", COLOR_CLICK_BUTTON)
	_current_button = label
	deley.stop()
	_on_hover(label)

func _on_mouse_exit_label(label):
	label.set("custom_colors/font_color", COLOR_DEFAUL_BUTTON)
	_current_button = null
	deley.start()

func _on_deley_timeout():
	anim.play_backwards("hover")

func _on_anim_animation_started(anim_name):
	if anim_name == "hover":
		_can_click = false

func _on_anim_animation_finished(anim_name):
	if anim_name == "hover":
		_can_click = true

func _on_hover(label):
	var _button = label.get_parent()
	
	var _position_y = _button.get("rect_position").y + (_button.get("rect_size").y / 2)
	pivot_1.position.y = _position_y
	pivot_2.position.y = _position_y
	
	var _positionx_x1 = (label.get("rect_position").x + label.get("rect_size").x) + 8
	var _position_x2 = label.get("rect_position").x - 8
	pivot_1.position.x = _positionx_x1
	pivot_2.position.x = _position_x2
	
	anim.play("hover")

func _on_click(label):
	anim.play("click")
	yield(anim, "animation_finished")







