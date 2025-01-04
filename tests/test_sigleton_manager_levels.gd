class_name TestSigletonManagerScene
extends GdUnitTestSuite

var _sigleton_manager_scene = null

var _levels_files = ["levelA", "levelB", "levelC"]

var _temp_dir = create_temp_dir("testlevels")

func _create_fake_levels():
	for _level in _levels_files:
		var _path = _temp_dir + "/" + _level
		var _file = File.new()
		var _err = _file.open(_path, File.WRITE)
		if _err == OK:
			_file.store_string("testscene")
		_file.close()

func before():
	_create_fake_levels()
	_sigleton_manager_scene = auto_free(load("res://sligletons/manager_scene/src.gd").new())
	_sigleton_manager_scene.LEVELS_PATH = _temp_dir
	add_child(_sigleton_manager_scene)
	_sigleton_manager_scene.ROOT = _sigleton_manager_scene

func test_try_get_env_main():
	var _node_main_test = Node.new()
	_node_main_test.name = "main"
	_sigleton_manager_scene.add_child(_node_main_test)
	var _env = _sigleton_manager_scene._try_get_current_env()
	assert_int(_env).is_equal(_sigleton_manager_scene.Envs.MAIN)
	_node_main_test.queue_free()

func test_try_get_env_level():
	var _node_main_test = Node.new()
	_sigleton_manager_scene._levels["test_level"] = null
	_node_main_test.name = "test_level"
	_sigleton_manager_scene.add_child(_node_main_test)
	var _env = _sigleton_manager_scene._try_get_current_env()
	assert_int(_env).is_equal(_sigleton_manager_scene.Envs.LEVEL)
	_node_main_test.queue_free()

func test_try_get_env_generic():
	var _node_main_test = Node.new()
	_node_main_test.name = "test_level->generic"
	_sigleton_manager_scene.add_child(_node_main_test)
	var _env = _sigleton_manager_scene._try_get_current_env()
	assert_int(_env).is_equal(_sigleton_manager_scene.Envs.GENERIC)
	_node_main_test.queue_free()

func test_try_get_env_unknow():
	var _env = _sigleton_manager_scene._try_get_current_env()
	assert_int(_env).is_equal(_sigleton_manager_scene.Envs.UNKNOW)

func test_get_levels():
	var _levels = _sigleton_manager_scene._get_levels()
	var _files = _levels.keys()
	assert_array(_files).is_equal(_levels_files)
	var _dir = Directory.new()
	var _err = _dir.open(_sigleton_manager_scene.LEVELS_PATH)
	if _err == OK:
		for _level_file in _levels_files:
			_dir.remove(_sigleton_manager_scene.LEVELS_PATH + "/" + _level_file)

func test_get_levels_path_invalid():
	var _levels = _sigleton_manager_scene._get_levels()
	var _files = _levels.keys()
	assert_array(_files).is_empty()

func test_remove_current_scene():
	var _node_test = auto_free(Node.new())
	_node_test.name = "test_level"
	_sigleton_manager_scene.add_child(_node_test)
	var _err = _sigleton_manager_scene._remove_current_scene("test_level")
	assert_int(_err).is_equal(OK)

func test_remove_current_scene_no_scene_in_get_tree():
	var _err = _sigleton_manager_scene._remove_current_scene("test_level")
	assert_int(_err).is_equal(ERR_INVALID_DATA)

func test_set_scene_name_no_as_generic():
	var _test_scene = auto_free(Node.new())
	_sigleton_manager_scene._set_scene_name(_test_scene, "test_level", false)
	assert_str(_test_scene.name).is_equal("test_level")

func test_set_scene_name_as_generic():
	var _test_scene = auto_free(Node.new())
	_sigleton_manager_scene._set_scene_name(_test_scene, "test_level", true)
	assert_str(_test_scene.name).is_equal("test_level->generic")

