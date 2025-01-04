extends Node
class_name VirtualMember

var Groups = Modules.import("groups.tools.index.gd").get_data()

export(String) var _id

export(bool) var auto_remove = true
export(String) var group = ""

func get_id():
	return _id

func _exit_tree():
	var _err = Groups.free_virtual_group(group, _id)
	if _err != OK: printerr("Erro to remove vmember")
