@tool
class_name DBMAnager
extends Node

func create_level_db():
	var new_level_db: LevelDB = LevelDB.new()
	new_level_db.levels = get_all_level_data_files()
	ResourceSaver.save(new_level_db, "res://data_system/level/levelDB/levelDB.tres")
	ResourceLoader.load("res://data_system/level/levelDB/levelDB.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	if OS.has_feature("standalone"): EditorInterface.get_resource_filesystem().scan()
	print("levelDB created and saved in res://data_system/level/levelDB/levelDB.tres")

func create_achivements_db():
	var new_ahievement_db: AchievementDB = AchievementDB.new()
	new_ahievement_db.achievements = get_all_achievement_data_files()
	ResourceSaver.save(new_ahievement_db, "res://data_system/achievement/achievementDB/achievementDB.tres")
	ResourceLoader.load("res://data_system/achievement/achievementDB/achievementDB.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	if OS.has_feature("standalone"): EditorInterface.get_resource_filesystem().scan()
	print("levelDB created and saved in res://data_system/achievement/achievementDB/achievementDB.tres")

func get_all_level_data_files() -> Array[LevelData]:
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

func get_all_achievement_data_files() -> Array[AchievementData]:
	var achievement_array: Array[AchievementData]
	var data_folder_path: String = "res://data_system/achievement/data/"
	var dir = DirAccess.open(data_folder_path)
	var files: PackedStringArray
	if dir: files = dir.get_files()
	for file in files:
		var achievement_ = load(data_folder_path + file)
		if achievement_ is AchievementData:
			achievement_array.append(achievement_)
	return achievement_array
