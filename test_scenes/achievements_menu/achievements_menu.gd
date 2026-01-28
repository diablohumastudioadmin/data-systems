@tool
class_name AchievementsMenu
extends Control

#var achievementDB: Array[AchievementData] = load("res://data_system/achievement/achievementDB/achievementDB.tres").achievements
#
#var goto_achievement_presenter_pksc: PackedScene = preload("uid://u1r7eyb38s4c")
#
#func _ready() -> void:
	#populate_goto_level_buttons_container()
#
#func populate_goto_level_buttons_container():
	#for child:AchievementPresenter in %AchievementPresentersContainer.get_children():
		#child.free()
	#for achievement in achievementDB:
		#var new_goto_achievement_presenter: AchievementPresenter = goto_achievement_presenter_pksc.instantiate()
		#new_goto_achievement_presenter.achievement = achievement
		#%AchievementPresentersContainer.add_child(new_goto_achievement_presenter)
		#if Engine.is_editor_hint():
			#new_goto_achievement_presenter.owner = self
			#notify_property_list_changed()
#
#func _on_goto_main_manu_button_pressed() -> void:
	#var main_menu_pksc: PackedScene = load("uid://b8yuiden1ryt7")
	#SceneManagerSystem.change_scene(main_menu_pksc)
