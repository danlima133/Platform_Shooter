extends Node
class_name ModuleGroups

class VirtualGroup extends Node:
	var name_group = ""
	var _group = {}
	
	func _init(name_group):
		self.name_group = name_group
		name = name_group
	
	func _ready():
		_set_virtual_group()
	
	func _set_virtual_group():
		var _nodes = get_tree().get_nodes_in_group(name_group)
		var _vmembers = _group.values()
		for _node in _nodes:
			if not _node in _vmembers:
				if _node.has_node("VirtualMember"):
					var _virtual_member = _node.get_node("VirtualMember") as VirtualMember
					_group[_virtual_member.get_id()] = _node
	
	func update_group():
		_set_virtual_group()
	
	func get_vmember(id):
		return _group.get(id)
	
	func has_vmember(id):
		return _group.has(id)
	
	func delete_vmember(id):
		var _delete = _group.erase(id)
		
		if _delete:
			return OK
		return ERR_INVALID_DATA

var _virtual_groups = Node.new()

func _ready():
	add_child(_virtual_groups)

func is_group_valid(name_group):
	if is_inside_tree():
		return true if get_tree().get_first_node_in_group(name_group) else false
	return ERR_UNAVAILABLE

func has_nodes_in_group(name_group):
	if is_inside_tree():
		return true if get_tree().get_nodes_in_group(name_group).size() > 0 else false
	return ERR_UNAVAILABLE

func get_node_in_group(name_group):
	if is_inside_tree():
		return get_tree().get_first_node_in_group(name_group)
	return ERR_UNAVAILABLE

func get_nodes_in_group(name_group):
	if is_inside_tree():
		return get_tree().get_nodes_in_group(name_group)
	return ERR_UNAVAILABLE

func create_virtual_group(target_group):
	if is_inside_tree():
		if _virtual_groups.has_node(target_group):
			var _virtual_group = _virtual_groups.get_node(target_group)
			_virtual_group.update_group()
			return _virtual_group
		var _virtual_group = VirtualGroup.new(target_group)
		_virtual_group.name = target_group
		_virtual_groups.add_child(_virtual_group)
		return _virtual_group
	return null

func free_virtual_group(target_group, vmember = ""):
	if is_inside_tree():
		if _virtual_groups.has_node(target_group):
			var _vgroup = _virtual_groups.get_node(target_group)
			if not vmember.empty():
				if _vgroup.has_vmember(vmember):
					return _vgroup.delete_vmember(vmember)
				return ERR_INVALID_DATA
			_vgroup.queue_free()
			return OK
		return ERR_INVALID_DATA
	return ERR_UNAVAILABLE
