class_name LevelDBCreator
extends Resource

static func create_level_db():
	var new_level_db: LevelDB = LevelDB.new()
	new_level_db.levels = get_all_level_data_files()
	ResourceSaver.save(new_level_db, "res://data_system/level/levelDB/levelDB.tres")
	print("levelDB created and saved in res://data_system/level/levelDB/levelDB.tres")

static func get_all_level_data_files() -> Array[LevelData]:
	var level_array: Array[LevelData]
	var data_folder_path: String = "res://data_system/level/data/"
	var dir = DirAccess.open(data_folder_path)
	var files: PackedStringArray
	if dir: files = dir.get_files()
	for file in files:
		var level_ = load(data_folder_path + file)
		if level_ is LevelData:
			level_array.append(level_)
	return level_array
