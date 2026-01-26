extends EditorExportPlugin

func _get_name() -> String:
	return "MasterDBCreator"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		var masterDB_creator: MasterDBCreator = load("res://addons/diablo_huma_studio/masterDB_creator/masterDB_creator.tscn").instantiate()
		masterDB_creator.create_level_db()
		masterDB_creator.create_achivements_db()
