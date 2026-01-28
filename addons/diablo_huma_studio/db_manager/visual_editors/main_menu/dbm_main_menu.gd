@tool
class_name DBMMainMenu
extends Control

var create_data_type_menu_pksc: PackedScene = load("uid://cbexj6e2rp8yk")
var create_data_menu_pksc: PackedScene = load("res://addons/diablo_huma_studio/db_manager/visual_editors/create_data_menu/dbm_create_data_menu.tscn")
var view_data_table_menu_pksc: PackedScene = load("res://addons/diablo_huma_studio/db_manager/visual_editors/view_data_table_menu/dbm_view_data_table_menu.tscn")

func _on_create_data_type_button_pressed() -> void:
	SceneManagerSystem.change_scene(create_data_type_menu_pksc, {}, self)

func _on_create_data_button_pressed() -> void:
	SceneManagerSystem.change_scene(create_data_menu_pksc, {}, self)

func _on_view_data_table_button_pressed() -> void:
	SceneManagerSystem.change_scene(view_data_table_menu_pksc, {}, self)
