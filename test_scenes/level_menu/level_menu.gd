@tool
class_name LevelMenu
extends Control

var levelDB: Array[LevelData] = load("res://data_system/level/levelDB/levelDB.tres").levels

var goto_level_button_pksc: PackedScene = preload("uid://e5hlu5j1y33s")

func _ready() -> void:
	populate_goto_level_buttons_container()

func populate_goto_level_buttons_container():
	for child:GotoLevelButton in %GotoLevelButtonsContainer.get_children():
		child.free()
	for level in levelDB:
		var new_goto_level_button: GotoLevelButton = goto_level_button_pksc.instantiate()
		new_goto_level_button.level = level
		new_goto_level_button.name = level.name
		%GotoLevelButtonsContainer.add_child(new_goto_level_button)
		if Engine.is_editor_hint():
			new_goto_level_button.owner = self
			notify_property_list_changed()


func _on_go_to_main_menu_button_pressed() -> void:
	var main_menu_pksc: PackedScene = load("uid://b8yuiden1ryt7")
	SceneManagerSystem.change_scene(main_menu_pksc)
