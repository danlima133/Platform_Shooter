extends Node

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_0:
			ManagerScenes.go_to_level("level_easy", ManagerScenes._current_level)
