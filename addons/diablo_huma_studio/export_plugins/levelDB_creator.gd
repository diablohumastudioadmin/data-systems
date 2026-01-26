extends EditorExportPlugin

func _get_name() -> String:
	return "LevelDBCreator"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	LevelDBCreator.create_level_db()
