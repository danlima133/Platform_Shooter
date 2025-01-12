extends CanvasLayer

export(Dictionary) var version = {
	"major": 0,
	"minor": 0,
	"patch": 0,
	"pre_release": "",
	"pre_release_version": 0
} setget _set_version

onready var version_label = $hud/VBoxContainer/version

func _set_version(value):
	version = value
	if version_label:
		if value["pre_release"].empty():
			version_label.text = \
			"%s.%s.%s" % [version["major"], version["minor"], version["patch"]]
		else:
			version_label.text = \
			"%s.%s.%s-%s.%s" % [version["major"], version["minor"], version["patch"], version["pre_release"], version["pre_release_version"]]

func _ready():
	_set_version(version)

func _on_buttons_click_button(id):
	match id:
		"button_play":
			ManagerScenes.go_to_level("level_easy")
		"button_settings":
			pass
		"button_exit":
			get_tree().quit()
