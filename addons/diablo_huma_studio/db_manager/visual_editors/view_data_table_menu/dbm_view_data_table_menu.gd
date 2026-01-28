@tool
class_name DBMViewDataTableMenu
extends Control

var selected_data_type: String = ""
var main_menu_pksc: PackedScene = load("uid://dwucurqrvby08")
var _available_types: Array[Dictionary] = []

func _ready() -> void:
	_populate_data_type_selector()

func _populate_data_type_selector() -> void:
	%DataTypeSelector.clear()
	_available_types = DataTypeUtils.get_available_data_types()
	if _available_types.is_empty():
		%DataTypeSelector.add_item("No data types found")
		%DataTypeSelector.disabled = true
		%StatusLabel.text = "No data types available"
		return
	for type_info in _available_types:
		%DataTypeSelector.add_item(type_info["class_name"])
	if not selected_data_type.is_empty():
		for i in _available_types.size():
			if _available_types[i]["class_name"] == selected_data_type:
				%DataTypeSelector.selected = i
				break
	_on_data_type_selector_item_selected(%DataTypeSelector.selected)

func _on_data_type_selector_item_selected(index: int) -> void:
	if index < 0 or index >= _available_types.size():
		return
	selected_data_type = _available_types[index]["class_name"]
	_load_data_table()

func _load_data_table() -> void:
	%DataTree.clear()

	var script_path: String = DataTypeUtils.get_script_path(selected_data_type)
	var script: GDScript = load(script_path)
	if script == null:
		%StatusLabel.text = "Failed to load script"
		return
	var instance: Resource = script.new()
	var properties: Array[Dictionary] = DataTypeUtils.get_export_properties(instance)

	var column_count: int = 1 + properties.size()
	%DataTree.columns = column_count
	%DataTree.column_titles_visible = true
	%DataTree.set_column_title(0, "id")
	%DataTree.set_column_expand(0, true)
	for i in properties.size():
		%DataTree.set_column_title(i + 1, properties[i].name)
		%DataTree.set_column_expand(i + 1, true)

	var root: TreeItem = %DataTree.create_item()
	%DataTree.hide_root = true

	var data_folder: String = DataTypeUtils.get_data_folder_path(selected_data_type)
	var dir: DirAccess = DirAccess.open(data_folder)
	if dir == null:
		%StatusLabel.text = "No data folder found"
		return

	var record_count: int = 0
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(data_folder + file_name)
			if res != null:
				var item: TreeItem = %DataTree.create_item(root)
				item.set_text(0, str(res.id) if "id" in res else "?")
				for i in properties.size():
					var value: Variant = res.get(properties[i].name)
					item.set_text(i + 1, str(value) if value != null else "")
				record_count += 1
		file_name = dir.get_next()

	%StatusLabel.text = "Showing %d record(s)" % record_count

func _on_back_button_pressed() -> void:
	SceneManagerSystem.change_scene(main_menu_pksc, {}, self)
