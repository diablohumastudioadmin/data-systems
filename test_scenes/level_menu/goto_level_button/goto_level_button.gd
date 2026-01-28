@tool
class_name GotoLevelButton
extends Button

#@export var level: LevelData :
	#set(new_value):
		#level = new_value
		#if is_node_ready():
			#_set_visuals()
#
#func _ready() -> void:
	#if Engine.is_editor_hint(): pressed.connect(_on_pressed)
	#if level:
		#name = level.name
		#_set_visuals()
#
#func _set_visuals():
	#text = "Goto " + level.name + " Level"
#
#func _on_pressed() -> void:
	#var game_pksc: PackedScene = load("res://test_scenes/game/game.tscn")
	#SceneManagerSystem.change_scene(game_pksc, {"level": level})
