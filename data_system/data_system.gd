@tool
extends Node

func _init() -> void:
	if not OS.has_feature("standalone"):
		LevelDBCreator.create_level_db()
