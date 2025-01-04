class_name TestSigletonModules
extends GdUnitTestSuite

const MODULE_TEST_PATH = "moduletest.gd"
const PACKAGE_TEST_PATH = "tools"

const __source = "res://tests/test_sigleton_modules.gd"

var _sigleton_modules = null
var _temp_dir = ""
var _module_test = \
"""
extends Node
const test_value = 50
func get_test_value():
	return test_value
"""

func _create_module_test():
	var _file = File.new()
	var _err = _file.open(_sigleton_modules.ROOT + MODULE_TEST_PATH, File.WRITE)
	if _err == OK:
		_file.store_string(_module_test)
	_file.close()

func _create_package_test():
	var _dir = Directory.new()
	_dir.make_dir(_sigleton_modules.ROOT + PACKAGE_TEST_PATH)

func before():
	_temp_dir = create_temp_dir("modules")
	_sigleton_modules = auto_free(load("res://sligletons/Modules.gd").new())
	_sigleton_modules.ROOT = _temp_dir
	_create_module_test()
	_create_package_test()

func test_is_package():
	var _pathrray = ["com", "tools", "package"]
	var _res = _sigleton_modules._is_package(_pathrray)
	assert_bool(_res).is_equal(true)

func test_not_is_package():
	var _pathrray = ["com", "tools", "package", "modules", "gd"]
	var _res = _sigleton_modules._is_package(_pathrray)
	assert_bool(_res).is_equal(false)

func test_is_module():
	var _pathrray = ["com", "tools", "package", "modules", "gd"]
	var _res = _sigleton_modules._is_module(_pathrray)
	assert_bool(_res).is_equal(true)

func test_not_is_module():
	var _pathrray = ["com", "tools", "package"]
	var _res = _sigleton_modules._is_module(_pathrray)
	assert_bool(_res).is_equal(false)

func test_get_pathrray_by_string():
	var _path = "com.tools.package"
	var _pathrray = _sigleton_modules._get_pathrray_by_string(_path)
	assert_array(_pathrray).is_equal(["com", "tools", "package"])

func test_get_pathrray_by_string_with_one_path():
	var _path = "com"
	var _pathrray = _sigleton_modules._get_pathrray_by_string(_path)
	assert_array(_pathrray).is_equal(["com"])

func test_get_string_by_pathrray_type_package_as_path():
	var _pathrray = ["com", "tools", "package"]
	var _path = _sigleton_modules._get_string_by_pathrray(_pathrray)
	assert_str(_path).is_equal("com/tools/package")

func test_get_string_by_pathrray_type_package_as_path_module():
	var _pathrray = ["com", "tools", "package"]
	var _path = _sigleton_modules._get_string_by_pathrray(_pathrray, true)
	assert_str(_path).is_equal("com.tools.package")

func test_get_string_by_pathrray_type_module_as_path():
	var _pathrray = ["com", "tools", "package", "module", "gd"]
	var _path = _sigleton_modules._get_string_by_pathrray(_pathrray)
	assert_str(_path).is_equal("com/tools/package/module.gd")

func test_get_string_by_pathrray_type_module_as_path_module():
	var _pathrray = ["com", "tools", "package", "module", "gd"]
	var _path = _sigleton_modules._get_string_by_pathrray(_pathrray, true)
	assert_str(_path).is_equal("com.tools.package.module.gd")

func test_get_module_by_pathrray_valid():
	var _pathrray = ["moduletest", "gd"]
	var _module = _sigleton_modules._get_module(_pathrray)
	var _module_name = ""
	var _module_data = null
	_module_name = _module.get_name()
	_module_data = _module.get_data()
	assert_str(_module_name).is_not_empty()
	assert_object(_module_data).is_not_null()
	_module.free()

func test_get_module_by_pathrray_not_valid():
	var _pathrray = ["module", "gd"]
	var _module = _sigleton_modules._get_module(_pathrray)
	var _module_name = ""
	var _module_data = null
	_module_name = _module.get_name()
	_module_data = _module.get_data()
	assert_str(_module_name).is_empty()
	assert_object(_module_data).is_null()
	_module.free()

func test_get_package_by_pathrray():
	var _pathrray = ["tools"]
	var _package = _sigleton_modules._get_package(_pathrray)
	var _package_name = ""
	_package_name = _package.get_name()
	assert_str(_package_name).is_not_empty()

func test_get_package_by_pathrray_invalid():
	var _pathrray = ["tool"]
	var _package = _sigleton_modules._get_package(_pathrray)
	var _package_name = ""
	var _package_modules = []
	_package_name = _package.get_name()
	_package_modules = _package.get_all_modules()
	assert_str(_package_name).is_empty()
	assert_array(_package_modules).is_empty()
