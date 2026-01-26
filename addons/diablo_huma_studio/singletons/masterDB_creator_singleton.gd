extends Node

func _init() -> void:
	if not OS.has_feature("standalone"):
		var masterDB_creator: MasterDBCreator = load("res://addons/diablo_huma_studio/masterDB_creator/masterDB_creator.tscn").instantiate()
		masterDB_creator.create_level_db()
		masterDB_creator.create_achivements_db()
		print("level db created from singleton at standalone Run F5 or F6")
