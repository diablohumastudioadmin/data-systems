@tool
extends EditorPlugin

var tool_submenu_name: String = "MasterDBCreator" 
var tool_submenu_popup: PopupMenu = load("uid://cmq3nc5ag8qc7").new()
var export_plugin: EditorExportPlugin = load("uid://dvscre0wbxii2").new()
var stand_alone_singleton_name: String = "StandAloneDBCreator"
var stand_alone_singleton_path: String = "uid://y7xt2blhe5nu"
var db_manager_singleton_name: String = "DBManager"
var db_manager_singleton_path: String = "uid://dvf42gydx8g0q"

var menu: PopupMenu = PopupMenu.new()

func _enable_plugin() -> void:
	add_autoload_singleton(stand_alone_singleton_name, uid_to_path(stand_alone_singleton_path))
	add_autoload_singleton(db_manager_singleton_name, uid_to_path(db_manager_singleton_path))

func _disable_plugin() -> void:
	remove_autoload_singleton(stand_alone_singleton_name)
	remove_autoload_singleton(db_manager_singleton_name)

func _enter_tree() -> void:
	add_export_plugin(export_plugin)
	menu.add_submenu_node_item(tool_submenu_name, tool_submenu_popup)
	add_tool_submenu_item("DHS_DB_Manager", menu)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	menu.clear(true)
	remove_tool_menu_item("DHS_DB_Manager")

static func uid_to_path(uid_string: String) -> String:
	var id: int = ResourceUID.text_to_id(uid_string)
	if ResourceUID.has_id(id):
		return ResourceUID.get_id_path(id)
	else:
		printerr("Invalid or unknown UID: ", uid_string)
		return "" 
