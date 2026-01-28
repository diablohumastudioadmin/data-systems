@tool
class_name Game
extends Control

#@export var level: LevelData: 
	#set(new_value):
		#level = new_value
		#if is_node_ready():
			#_set_visuals()
#
#func _ready() -> void:
	#if level:
		#_set_visuals()
#
#func _set_visuals():
	#%BackgroundColorRect.color = level.game_backgound_color
	#%Title.text = level.name
#
#func _on_return_button_pressed() -> void:
	#var level_menu_pksc: PackedScene = load("uid://cwiqpoedqo816")
	#SceneManagerSystem.change_scene(level_menu_pksc)
