@tool
extends EditorPlugin

var tool_submenus: Dictionary[String, PopupMenu] = {
	"MasterDBCreator" : load("uid://cmq3nc5ag8qc7").new()
}
var export_plugins: Array[EditorExportPlugin] = [
	load("uid://dvscre0wbxii2").new()
]
var singletons: Dictionary[String, String] = {
	"MasterDBCreatorSingleton": "res://addons/diablo_huma_studio/singletons/masterDB_creator_singleton.gd"
}

var menu: PopupMenu = PopupMenu.new()

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	for export_plugin in export_plugins:
		add_export_plugin(export_plugin)
	for singleton in singletons:
		add_autoload_singleton(singleton, singletons[singleton])
	for tool_submenu_key in tool_submenus:
		menu.add_submenu_node_item(tool_submenu_key, tool_submenus[tool_submenu_key])
	add_tool_submenu_item("DiabloHumaStudio", menu)

func _exit_tree() -> void:
	for export_plugin in export_plugins:
		remove_export_plugin(export_plugin)
	for singleton in singletons:
		remove_autoload_singleton(singleton)
	menu.clear(true)
	remove_tool_menu_item("DiabloHumaStudio")
