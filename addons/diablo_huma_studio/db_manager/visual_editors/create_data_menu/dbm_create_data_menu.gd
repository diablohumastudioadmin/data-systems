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
		_property_widgets[prop.name] = {"widget": widget, "type": prop.type}

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
			var line_edit: LineEdit = LineEdit.new()
			line_edit.placeholder_text = "Comma-separated values"
			return line_edit
		TYPE_OBJECT:
			var line_edit: LineEdit = LineEdit.new()
			line_edit.placeholder_text = "res://path/to/resource.tres"
			return line_edit
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
			return Vector2(widget.get_node("x").value, widget.get_node("y").value)
		TYPE_VECTOR3:
			return Vector3(widget.get_node("x").value, widget.get_node("y").value, widget.get_node("z").value)
		TYPE_COLOR:
			return widget.color
		TYPE_NODE_PATH:
			return NodePath(widget.text)
		_:
			return widget.text if widget is LineEdit else null

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
