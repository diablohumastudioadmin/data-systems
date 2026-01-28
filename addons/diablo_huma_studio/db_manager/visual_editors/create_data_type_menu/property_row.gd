@tool
class_name DBMPropertyRow
extends HBoxContainer

const COLOR_NORMAL: Color = Color.WHITE
const COLOR_ERROR: Color = Color.RED

signal remove_requested(row: Node)
signal property_name_changed()

func _ready() -> void:
	%PropertyNameInput.text_changed.connect(_on_text_changed)

func _on_text_changed(_new_text: String) -> void:
	property_name_changed.emit()

func get_property_name() -> String:
	return %PropertyNameInput.text.strip_edges()

func _get_property_type() -> String:
	return %PropertyTypeSelect.get_item_text(%PropertyTypeSelect.selected)

func get_property_data() -> Dictionary:
	return {
		"name": get_property_name(),
		"type": _get_property_type()
	}

func set_error_state(has_error: bool) -> void:
	%PropertyNameInput.modulate = COLOR_ERROR if has_error else COLOR_NORMAL

func _on_remove_button_pressed() -> void:
	queue_free()
