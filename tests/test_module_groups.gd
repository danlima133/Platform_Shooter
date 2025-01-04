class_name TestModuleGroups
extends GdUnitTestSuite

const GROUP_TEST = "group"
const NAME_NODE = "test_node"

var _module_groups = null
var _group_test = null

func before():
	_module_groups = auto_free(load("res://modules/groups/tools/index.gd").new())
	_group_test = auto_free(Node.new())
	_group_test.name = NAME_NODE
	_group_test.add_to_group(GROUP_TEST)

func test_is_group_valid_in_scene_tree_with_group_valid():
	get_parent().add_child(_group_test)
	get_parent().add_child(_module_groups)
	var _res = _module_groups.is_group_valid(GROUP_TEST)
	assert_bool(_res).is_true()
	get_parent().remove_child(_group_test)
	get_parent().remove_child(_module_groups)

func test_is_group_valid_in_scene_tree_with_group_invalid():
	get_parent().add_child(_group_test)
	get_parent().add_child(_module_groups)
	var _res = _module_groups.is_group_valid("test")
	assert_bool(_res).is_false()
	get_parent().remove_child(_group_test)
	get_parent().remove_child(_module_groups)

func test_is_group_valid_out_scene_tree():
	var _res = _module_groups.is_group_valid(GROUP_TEST)
	assert_int(_res).is_equal(ERR_UNAVAILABLE)
