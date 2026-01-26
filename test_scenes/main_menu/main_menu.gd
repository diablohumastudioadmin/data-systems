class_name MainMenu
extends Control

func _on_goto_levels_menu_button_pressed() -> void:
	var level_menu_pksc: PackedScene = load("uid://cwiqpoedqo816")
	SceneManagerSystem.change_scene(level_menu_pksc)


func _on_goto_achievements_menu_button_pressed() -> void:
	var achievements_menu_pksc: PackedScene = load("uid://dgvpqapubyxx4")
	SceneManagerSystem.change_scene(achievements_menu_pksc)
