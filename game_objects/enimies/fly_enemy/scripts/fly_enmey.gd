extends Node2D
tool

onready var vSignals = Modules.import("utils.signals.tools.vsignal.gd").get_data() if get_tree().root.has_node("Modules") else null

enum Sides {
	LEFT
	RIGHT
}

export(SpriteFrames) var texture = null setget _set_texture
export(Sides) var side setget _set_side
export(float) var amplitude
export(float) var frequency
export(Shape2D) var enemy_shape
export(Vector2) var shape_offset
export(int) var damage
export(int) var life
export(bool) var debug

onready var pivot = $pivot
onready var sprite = $pivot/sprite
onready var hit_box = $pivot/hit_box
onready var hurt_box = $pivot/hurt_box

var _time = 0

func _set_texture(value):
	texture = value
	_set_sprite()

func _set_side(value):
	side = value
	_udpadate_side()

func _udpate_time(delta):
	_time += delta

func _move(delta):
	var _dir = sin(2 * PI * frequency * _time)
	pivot.position.y = (_dir * amplitude)

func _set_sprite():
	if texture:
		if sprite:
			sprite.frames = texture
			if texture.has_animation("fly"):
				sprite.play("fly")
			else: printerr("Set SpriteFrames with animation 'fly'")

func _udpadate_side():
	if sprite:
		sprite.flip_h = (true if side == Sides.LEFT else false)

func _draw():
	if debug:
		var _position_local = to_local(global_position)
		var _position_with_velocity = _position_local + Vector2(0, amplitude)
		var _to = _position_local.y - amplitude
		var _at = _to + (2 * amplitude)
		draw_line(Vector2(_position_local.x, _to), Vector2(_position_local.x, _at), Color.red, 2)
		draw_circle(to_local(global_position), 3, Color.black)

func _ready():
	_set_sprite()
	_udpadate_side()
	if not Engine.editor_hint:
		hurt_box.set_hurt(life)
		hurt_box.update_hurt_max()
		hit_box.set_hit(damage)
		if enemy_shape:
			var _shape_hit_box = CollisionShape2D.new()
			var _shape_hurt_box = CollisionShape2D.new()
			_shape_hit_box.shape = enemy_shape
			_shape_hurt_box.shape = enemy_shape
			_shape_hit_box.position = shape_offset
			_shape_hurt_box.position = shape_offset
			hit_box.add_child(_shape_hit_box)
			hurt_box.add_child(_shape_hurt_box)

func _process(delta):
	if not Engine.editor_hint:
		_udpate_time(delta)
		_move(delta)
	update()

func get_time():
	return _time

func _on_hurt_box_at_hurt_factor():
	vSignals.emmit_vsignal("enemy_death")
	queue_free()
