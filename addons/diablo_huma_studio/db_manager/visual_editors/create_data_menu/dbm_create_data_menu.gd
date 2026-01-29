@tool
class_name DBMCreateDataMenu
extends Control

var selected_data_type: String = ""
var main_menu_pksc: PackedScene = load("uid://dwucurqrvby08")
var _property_widgets: Dictionary = {}
var _available_types: Array[Dictionary] = []

func _ready() -> void:
	_populate_data_type_selector()

func _populate_data_type_selector() -> void:
	%DataTypeSelector.clear()
	_available_types = DataTypeUtils.get_available_data_types()
	if _available_types.is_empty():
		%DataTypeSelector.add_item("No data types found")
		%DataTypeSelector.disabled = true
		%SaveButton.disabled = true
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
	_build_property_form()

func _build_property_form() -> void:
	for child in %PropertiesContainer.get_children():
		child.queue_free()
	_property_widgets.clear()
	%FeedbackLabel.visible = false

	var script_path: String = DataTypeUtils.get_script_path(selected_data_type)
	var script: GDScript = load(script_path)
	if script == null:
		return
	var instance: Resource = script.new()
	var properties: Array[Dictionary] = DataTypeUtils.get_export_properties(instance)

	for prop in properties:
		var row: HBoxContainer = HBoxContainer.new()
		var label: Label = Label.new()
		label.text = prop.name + ":"
		label.custom_minimum_size = Vector2(250, 0)
		row.add_child(label)

		var widget: Control = _create_input_widget(prop)
		widget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(widget)

		%PropertiesContainer.add_child(row)
		var prop_info: Dictionary = {
			"widget": widget,
			"type": prop.type,
			"hint": prop.get("hint", 0),
			"hint_string": prop.get("hint_string", ""),
		}
		_property_widgets[prop.name] = prop_info

func _create_input_widget(prop: Dictionary) -> Control:
	match prop.type:
		TYPE_STRING:
			var line_edit: LineEdit = LineEdit.new()
			line_edit.placeholder_text = "Enter " + prop.name
			return line_edit
		TYPE_INT:
			var spin: SpinBox = SpinBox.new()
			spin.step = 1
			spin.rounded = true
			spin.allow_greater = true
			spin.allow_lesser = true
			spin.min_value = -999999
			spin.max_value = 999999
			return spin
		TYPE_FLOAT:
			var spin: SpinBox = SpinBox.new()
			spin.step = 0.01
			spin.allow_greater = true
			spin.allow_lesser = true
			spin.min_value = -999999.0
			spin.max_value = 999999.0
			return spin
		TYPE_BOOL:
			var check: CheckBox = CheckBox.new()
			return check
		TYPE_VECTOR2:
			var hbox: HBoxContainer = HBoxContainer.new()
			for axis in ["x", "y"]:
				var lbl: Label = Label.new()
				lbl.text = axis.to_upper() + ":"
				hbox.add_child(lbl)
				var spin: SpinBox = SpinBox.new()
				spin.step = 0.01
				spin.allow_greater = true
				spin.allow_lesser = true
				spin.name = axis
				spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(spin)
			return hbox
		TYPE_VECTOR3:
			var hbox: HBoxContainer = HBoxContainer.new()
			for axis in ["x", "y", "z"]:
				var lbl: Label = Label.new()
				lbl.text = axis.to_upper() + ":"
				hbox.add_child(lbl)
				var spin: SpinBox = SpinBox.new()
				spin.step = 0.01
				spin.allow_greater = true
				spin.allow_lesser = true
				spin.name = axis
				spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(spin)
			return hbox
		TYPE_COLOR:
			var picker: ColorPickerButton = ColorPickerButton.new()
			picker.custom_minimum_size = Vector2(100, 40)
			return picker
		TYPE_ARRAY:
			return _create_array_widget(prop)
		TYPE_DICTIONARY:
			return _create_dictionary_widget()
		TYPE_OBJECT:
			return _create_resource_widget()
		TYPE_NODE_PATH:
			var line_edit: LineEdit = LineEdit.new()
			line_edit.placeholder_text = "Node/Path"
			return line_edit
		_:
			var line_edit: LineEdit = LineEdit.new()
			line_edit.placeholder_text = "Value"
			return line_edit

func _get_value_from_widget(prop_name: String) -> Variant:
	var info: Dictionary = _property_widgets[prop_name]
	var widget: Control = info["widget"]
	var type: int = info["type"]
	match type:
		TYPE_STRING:
			return widget.text
		TYPE_INT:
			return int(widget.value)
		TYPE_FLOAT:
			return widget.value
		TYPE_BOOL:
			return widget.button_pressed
		TYPE_VECTOR2:
			var x: float = widget.get_node("x").value
			var y: float = widget.get_node("y").value
			return Vector2(x, y)
		TYPE_VECTOR3:
			var x: float = widget.get_node("x").value
			var y: float = widget.get_node("y").value
			var z: float = widget.get_node("z").value
			return Vector3(x, y, z)
		TYPE_COLOR:
			return widget.color
		TYPE_NODE_PATH:
			return NodePath(widget.text)
		TYPE_ARRAY:
			return _get_array_value(widget, info)
		TYPE_DICTIONARY:
			return _get_dictionary_value(widget)
		TYPE_OBJECT:
			return _get_resource_value(widget)
		_:
			if widget is LineEdit:
				return widget.text
			return null

# region Array widget

func _get_element_type_from_hint(hint_string: String) -> int:
	if hint_string.is_empty():
		return TYPE_STRING
	var parts: PackedStringArray = hint_string.split(":")
	if parts.size() > 0:
		var type_part: String = parts[0].split("/")[0]
		if type_part.is_valid_int():
			return int(type_part)
	return TYPE_STRING

func _create_element_widget(element_type: int) -> Control:
	match element_type:
		TYPE_STRING, TYPE_STRING_NAME:
			var le: LineEdit = LineEdit.new()
			le.placeholder_text = "Value"
			return le
		TYPE_INT:
			var spin: SpinBox = SpinBox.new()
			spin.step = 1
			spin.rounded = true
			spin.allow_greater = true
			spin.allow_lesser = true
			spin.min_value = -999999
			spin.max_value = 999999
			return spin
		TYPE_FLOAT:
			var spin: SpinBox = SpinBox.new()
			spin.step = 0.01
			spin.allow_greater = true
			spin.allow_lesser = true
			spin.min_value = -999999.0
			spin.max_value = 999999.0
			return spin
		TYPE_BOOL:
			var check: CheckBox = CheckBox.new()
			return check
		TYPE_COLOR:
			var picker: ColorPickerButton = ColorPickerButton.new()
			picker.custom_minimum_size = Vector2(100, 40)
			return picker
		_:
			var le: LineEdit = LineEdit.new()
			le.placeholder_text = "Value"
			return le

func _get_value_from_element(
	widget: Control, element_type: int
) -> Variant:
	match element_type:
		TYPE_STRING, TYPE_STRING_NAME:
			return (widget as LineEdit).text
		TYPE_INT:
			return int((widget as SpinBox).value)
		TYPE_FLOAT:
			return (widget as SpinBox).value
		TYPE_BOOL:
			return (widget as CheckBox).button_pressed
		TYPE_COLOR:
			return (widget as ColorPickerButton).color
		_:
			if widget is LineEdit:
				return widget.text
			return ""

func _create_array_widget(prop: Dictionary) -> PanelContainer:
	var element_type: int = _get_element_type_from_hint(
		prop.get("hint_string", "")
	)
	var panel: PanelContainer = PanelContainer.new()
	var vbox: VBoxContainer = VBoxContainer.new()
	panel.add_child(vbox)

	var header: HBoxContainer = HBoxContainer.new()
	var header_label: Label = Label.new()
	header_label.text = "Array (0 items)"
	header_label.name = "header_label"
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_label)

	var add_btn: Button = Button.new()
	add_btn.text = "Add"
	header.add_child(add_btn)
	vbox.add_child(header)

	var items: VBoxContainer = VBoxContainer.new()
	items.name = "items"
	vbox.add_child(items)

	add_btn.pressed.connect(
		_add_array_item.bind(items, header_label, element_type)
	)
	return panel

func _add_array_item(
	container: VBoxContainer,
	header_label: Label,
	element_type: int,
) -> void:
	var row: HBoxContainer = HBoxContainer.new()

	var idx_label: Label = Label.new()
	idx_label.text = "#" + str(container.get_child_count())
	idx_label.custom_minimum_size = Vector2(40, 0)
	row.add_child(idx_label)

	var el_widget: Control = _create_element_widget(element_type)
	el_widget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(el_widget)

	var remove_btn: Button = Button.new()
	remove_btn.text = "Remove"
	remove_btn.pressed.connect(
		_remove_array_item.bind(row, container, header_label)
	)
	row.add_child(remove_btn)

	container.add_child(row)
	header_label.text = "Array (%d items)" % container.get_child_count()

func _remove_array_item(
	row: HBoxContainer,
	container: VBoxContainer,
	header_label: Label,
) -> void:
	container.remove_child(row)
	row.queue_free()
	for i in container.get_child_count():
		var child_row: HBoxContainer = container.get_child(i)
		var idx_label: Label = child_row.get_child(0) as Label
		if idx_label:
			idx_label.text = "#" + str(i)
	header_label.text = "Array (%d items)" % container.get_child_count()

func _get_array_value(
	widget: Control, info: Dictionary
) -> Array:
	var items: VBoxContainer = widget.get_child(0).get_node("items")
	var result: Array = []
	var element_type: int = _get_element_type_from_hint(
		info.get("hint_string", "")
	)
	for row in items.get_children():
		if row is HBoxContainer:
			var el_widget: Control = row.get_child(1)
			result.append(
				_get_value_from_element(el_widget, element_type)
			)
	return result

# endregion

# region Dictionary widget

func _create_dictionary_widget() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var vbox: VBoxContainer = VBoxContainer.new()
	panel.add_child(vbox)

	var header: HBoxContainer = HBoxContainer.new()
	var header_label: Label = Label.new()
	header_label.text = "Dictionary (0 entries)"
	header_label.name = "header_label"
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_label)

	var add_btn: Button = Button.new()
	add_btn.text = "Add Entry"
	header.add_child(add_btn)
	vbox.add_child(header)

	var entries: VBoxContainer = VBoxContainer.new()
	entries.name = "entries"
	vbox.add_child(entries)

	add_btn.pressed.connect(
		_add_dict_entry.bind(entries, header_label)
	)
	return panel

func _add_dict_entry(
	container: VBoxContainer, header_label: Label
) -> void:
	var row: HBoxContainer = HBoxContainer.new()

	var key_edit: LineEdit = LineEdit.new()
	key_edit.placeholder_text = "Key"
	key_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(key_edit)

	var value_edit: LineEdit = LineEdit.new()
	value_edit.placeholder_text = "Value"
	value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_edit)

	var remove_btn: Button = Button.new()
	remove_btn.text = "Remove"
	remove_btn.pressed.connect(
		_remove_dict_entry.bind(row, container, header_label)
	)
	row.add_child(remove_btn)

	container.add_child(row)
	var count: int = container.get_child_count()
	header_label.text = "Dictionary (%d entries)" % count

func _remove_dict_entry(
	row: HBoxContainer,
	container: VBoxContainer,
	header_label: Label,
) -> void:
	container.remove_child(row)
	row.queue_free()
	var count: int = container.get_child_count()
	header_label.text = "Dictionary (%d entries)" % count

func _get_dictionary_value(widget: Control) -> Dictionary:
	var entries: VBoxContainer = widget.get_child(0).get_node("entries")
	var result: Dictionary = {}
	for row in entries.get_children():
		if row is HBoxContainer:
			var key_edit: LineEdit = row.get_child(0) as LineEdit
			var val_edit: LineEdit = row.get_child(1) as LineEdit
			if key_edit and val_edit and not key_edit.text.is_empty():
				result[key_edit.text] = val_edit.text
	return result

# endregion

# region Resource widget

func _create_resource_widget() -> HBoxContainer:
	var hbox: HBoxContainer = HBoxContainer.new()

	var path_edit: LineEdit = LineEdit.new()
	path_edit.editable = false
	path_edit.placeholder_text = "No resource selected"
	path_edit.name = "path_edit"
	path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(path_edit)

	var browse_btn: Button = Button.new()
	browse_btn.text = "Browse..."
	hbox.add_child(browse_btn)

	var file_dialog: EditorFileDialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.tres", "Text Resource")
	file_dialog.add_filter("*.res", "Binary Resource")
	file_dialog.file_selected.connect(
		func(path: String) -> void: path_edit.text = path
	)
	hbox.add_child(file_dialog)

	browse_btn.pressed.connect(
		func() -> void: file_dialog.popup_centered(Vector2i(800, 600))
	)
	return hbox

func _get_resource_value(widget: Control) -> Resource:
	var path_edit: LineEdit = widget.get_node("path_edit")
	if path_edit and not path_edit.text.is_empty():
		return load(path_edit.text)
	return null

# endregion

func _on_save_button_pressed() -> void:
	%FeedbackLabel.visible = false
	if selected_data_type.is_empty():
		_show_error("No data type selected")
		return

	if "name" in _property_widgets:
		var name_value: String = str(_get_value_from_widget("name")).strip_edges()
		if name_value.is_empty():
			_show_error("Name cannot be blank")
			return
		if DataTypeUtils.data_exists(selected_data_type, name_value):
			_show_error("A record with name '%s' already exists" % name_value)
			return

	var script_path: String = DataTypeUtils.get_script_path(selected_data_type)
	var script: GDScript = load(script_path)
	if script == null:
		_show_error("Failed to load script: " + script_path)
		return

	var resource: Resource = script.new()
	resource.id = DataTypeUtils.get_next_id(selected_data_type)

	for prop_name in _property_widgets:
		var value: Variant = _get_value_from_widget(prop_name)
		resource.set(prop_name, value)

	var data_folder: String = DataTypeUtils.get_data_folder_path(selected_data_type)
	var file_name: String = DataTypeGenerator._to_snake_case(selected_data_type) + "_" + str(resource.name) + ".tres"
	var full_path: String = data_folder + file_name

	var err: Error = ResourceSaver.save(resource, full_path)
	if err != OK:
		_show_error("Failed to save resource (error code: %d)" % err)
		return
	load("res://diablo_huma_studio/db_manager/data/LevelData/level_data_1.tres")
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()

	_show_success("Saved: " + file_name)
	_build_property_form()

func _show_error(msg: String) -> void:
	%FeedbackLabel.visible = true
	%FeedbackLabel.add_theme_color_override("font_color", Color(0.55, 0, 0, 1))
	%FeedbackLabel.text = msg

func _show_success(msg: String) -> void:
	%FeedbackLabel.visible = true
	%FeedbackLabel.add_theme_color_override("font_color", Color(0, 0.55, 0, 1))
	%FeedbackLabel.text = msg

func _on_back_button_pressed() -> void:
	SceneManagerSystem.change_scene(main_menu_pksc, {}, self)
