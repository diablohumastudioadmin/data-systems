@tool
class_name DBMCreateDataTypeMenu
extends Control

@onready var property_row_scene: PackedScene = load("uid://cpygu4nskpf7o")

var errors: Array[String] = []

func _on_add_property_button_pressed() -> void:
	var new_row: DBMPropertyRow = property_row_scene.instantiate()
	%PropertiesContainer.add_child(new_row)
	new_row.property_name_changed.connect(_validate_all_properties)
	new_row.tree_exiting.connect(_on_property_row_removed)

func _on_property_row_removed() -> void:
	_validate_all_properties.call_deferred()

func _validate_all_properties() -> void:
	errors.clear()

	if get_data_type_name().strip_edges().is_empty():
		errors.append("Class name cannot be empty")

	var seen_names: Dictionary = {}
	for child in %PropertiesContainer.get_children():
		if child is DBMPropertyRow:
			var prop_name: String = child.get_property_name()
			var has_error: bool = false

			if prop_name.is_empty():
				errors.append("Property name cannot be empty")
				has_error = true
			elif prop_name in seen_names:
				errors.append("Duplicate property name: '%s'" % prop_name)
				has_error = true
				seen_names[prop_name].set_error_state(true)
			else:
				seen_names[prop_name] = child

			child.set_error_state(has_error)

	_update_errors_display()

func _update_errors_display() -> void:
	if errors.is_empty():
		%ErrorsLabel.visible = false
	else:
		%ErrorsLabel.visible = true
		%ErrorsLabel.text = "Found " + str(errors.size()) + " Errors \nErr1:" + errors[0]

func get_data_type_name() -> String:
	return %ClassNameInput.text

func get_properties() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for child in %PropertiesContainer.get_children():
		if child is DBMPropertyRow:
			properties.append(child.get_property_data())
	return properties

func _on_add_data_type_button_pressed() -> void:
	_validate_all_properties()
	if not errors.is_empty():
		return
	var result: int = DataTypeScriptGenerator.save(get_data_type_name().strip_edges(), get_properties())
	if result != OK:
		errors.append("Failed to save file (error code: %d)" % result)
		_update_errors_display()
