extends Node2D

var Groups = Modules.import("groups.tools.index.gd").get_data()

enum Sides {
	LEFT
	RIGHT
}

export(int) var velocity

onready var texture = $texture

var _side = Sides.LEFT
var _dir = 0

func _ready():
	match _side:
		Sides.LEFT:
			texture.flip_h = false
			_dir = 1
		Sides.RIGHT:
			texture.flip_h = true
			_dir = -1

func _physics_process(delta):
	translate(Vector2(_dir, 0) * velocity * delta)

func _kill():
	if Groups.is_group_valid("HUDlevel"):
		Groups.get_node_in_group("HUDlevel")._set_bullet(true)
	queue_free()

func _on_lifetime_timeout():
	_kill()

func _on_hit_box_hit(hit_box, hurt_box):
	var _levelset = Groups.get_node_in_group("levelset")
	if _levelset:
		_levelset.get_camera().shake(0.15, 150)
	_kill()
