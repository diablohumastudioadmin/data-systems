@tool
class_name AchievementPresenter
extends HBoxContainer

@export var achievement: AchievementData:
	set(new_value):
		achievement = new_value
		if is_node_ready():
			_set_visuals()

func _ready():
	name = achievement.name
	_set_visuals()

func _set_visuals():
	print(achievement)
	if achievement:
		%Name.text = achievement.name
	else: 
		%Name.text = "Placeholder Achievement"
