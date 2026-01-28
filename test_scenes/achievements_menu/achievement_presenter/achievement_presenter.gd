@tool
class_name AchievementPresenter
extends HBoxContainer

#@export var achievement: AchievementData:
	#set(new_value):
		#achievement = new_value
		#if is_node_ready():
			#_set_visuals()
#
#func _ready():
	#_set_visuals()
#
#func _set_visuals():
	#if achievement:
		#name = achievement.name
		#%Name.text = achievement.name
	#else: 
		#%Name.text = "Placeholder Achievement"
