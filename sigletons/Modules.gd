extends Node

var ROOT = "res://modules/"
const MODULE_EXTESION = "gd"

var _cache_modules = Node.new()

class Package:
	var _package_name = ""
	var _modules = {}
	
	func _init(package_name, modules):
		self._package_name = package_name
		_set_package(modules)
	
	func _set_package(modules):
		for _module in modules:
			_modules[_module.get_name()] = _module
	
	func get_module(module_name):
		return _modules.get(module_name)
	
	func get_all_modules():
		return _modules.values()
	
	func has_module(module_name):
		return _modules.has(module_name)
	
	func get_name():
		return _package_name

class Module extends Node:
	var _name_module = ""
	var _object:Object
	
	func _init(name_module, object):
		self._name_module = name_module
		self._object = object
		name = name_module
	
	func get_name():
		return _name_module
	
	func get_data():
		return _object

func import(path_module):
	var _pathrray = _get_pathrray_by_string(path_module)
	
	if _is_package(_pathrray):
		return _get_package(_pathrray)
	elif _is_module(_pathrray):
		return _get_module(_pathrray)

func modules_clear(modules = []):
	if modules.size() == 0:
		for _module in _cache_modules.get_children():
			_module.queue_free()
	else:
		for _module in modules:
			if _cache_modules.has_node(_module):
				_cache_modules.get_node(_module).queue_free()

func _ready():
	self.add_child(_cache_modules)

func _is_package(pathrray):
	var _last_path = pathrray[pathrray.size() - 1]
	if _last_path != MODULE_EXTESION:
		return true
	return false

func _is_module(pathrray):
	var _last_path = pathrray[pathrray.size() - 1]
	if _last_path == MODULE_EXTESION:
		return true
	return false

func _get_pathrray_by_string(string):
	var _pathrray = []
	_pathrray = string.split(".")
	if _pathrray.size() < 2:
		return [string]
	return _pathrray

func _get_string_by_pathrray(pathrray, as_path_module = false):
	var _path = ""
	var _pathrray = pathrray
	for _content in pathrray:
		if _content == MODULE_EXTESION:
			_path += "." + MODULE_EXTESION
			break
		_path += ("." if as_path_module else "/") + _content
	_path = _path.substr(1)
	return _path
	
func _get_package(pathrray:Array):
	var _path = ROOT + _get_string_by_pathrray(pathrray)
	var _dir = Directory.new()
	var _modules = []
	if _dir.dir_exists(_path):
		var _err = _dir.open(_path)
		if _err == OK:
			_dir.list_dir_begin()
			var _file = _dir.get_next()
			while _file != "":
				if _file.get_extension() == MODULE_EXTESION:
					var _file_name = _file.replace("." + MODULE_EXTESION, "")
					var _file_extension = _file.get_extension()
					var _module_pathrray = pathrray.duplicate()
					_module_pathrray.append(_file_name)
					_module_pathrray.append(_file_extension)
					_modules.append(_get_module(_module_pathrray))
				_file = _dir.get_next()
			return Package.new(pathrray[pathrray.size() - 1], _modules)
	return Package.new("", [])

func _get_module(pathrray):
	var _path = ROOT + _get_string_by_pathrray(pathrray)
	if ResourceLoader.exists(_path):
		var _module_name = _path.get_file().replace("." + MODULE_EXTESION, "")
		if _cache_modules.has_node(_module_name):
			return _cache_modules.get_node(_module_name)
		var _module_data = ResourceLoader.load(_path)
		var _object = _module_data.new()
		var _module = Module.new(_module_name, _object)
		_module.add_child(_object)
		_cache_modules.add_child(_module)
		return _module
	return Module.new("", null)
