class_name AchievementsMenu
extends Control


func _on_goto_main_manu_button_pressed() -> void:
	var main_menu_pksc: PackedScene = load("uid://b8yuiden1ryt7")
	SceneManagerSystem.change_scene(main_menu_pksc)
