@tool
class_name DBMMainMenu
extends Control

var create_data_type_menu: DBMCreateDataTypeMenu
var create_data_type_menu_pksc: PackedScene = load("uid://cbexj6e2rp8yk")

func _on_create_data_type_button_pressed() -> void:
	SceneManagerSystem.change_scene(create_data_type_menu_pksc, {}, self)
