@tool
extends EditorPlugin

var tool_submenus: Dictionary[String, PopupMenu] = {
	"LevelDBCreator" : load("uid://cmq3nc5ag8qc7").new()
}
var export_plugins: Array[EditorExportPlugin] = [
	load("uid://dvscre0wbxii2").new()
]

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	var menu: PopupMenu = PopupMenu.new()
	for tool_submenu_key in tool_submenus:
		menu.add_submenu_node_item(tool_submenu_key, tool_submenus[tool_submenu_key])
	for export_plugin in export_plugins:
		add_export_plugin(export_plugin)
	add_tool_submenu_item("DiabloHumaStudio", menu)

func _exit_tree() -> void:
	remove_tool_menu_item("DiabloHumaStudio")
