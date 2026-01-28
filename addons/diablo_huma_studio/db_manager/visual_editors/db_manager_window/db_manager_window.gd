@tool
class_name DBManagerWindow
extends Window

const BRAND_PATH: String = "res://diablo_huma_studio/"
const PLUGIN_FOLDER_NAME: String = "db_manager/"
const DATA_TYPES_FOLDER_NAME: String = "data_types/"
const DATA_FOLDER_NAME: String = "data/"

const DATA_TYPE_CLASS_PATH: String = "uid://dei5nvlls4n7f"

func _ready() -> void:
	create_data_types_folder()

func create_data_types_folder():
	if not DirAccess.dir_exists_absolute(BRAND_PATH + PLUGIN_FOLDER_NAME + DATA_FOLDER_NAME):
		DirAccess.make_dir_recursive_absolute(BRAND_PATH + PLUGIN_FOLDER_NAME + DATA_FOLDER_NAME)
	if not DirAccess.dir_exists_absolute(BRAND_PATH + PLUGIN_FOLDER_NAME + DATA_TYPES_FOLDER_NAME):
		DirAccess.make_dir_recursive_absolute(BRAND_PATH + PLUGIN_FOLDER_NAME + DATA_TYPES_FOLDER_NAME)
	if Engine.is_editor_hint():
		var fs := EditorInterface.get_resource_filesystem()
		if fs.is_scanning(): fs.filesystem_changed.connect(fs.scan, CONNECT_ONE_SHOT)
		else: fs.scan()

func create_tables():
	var dir = DirAccess.open(BRAND_PATH + PLUGIN_FOLDER_NAME + DATA_FOLDER_NAME)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			print("Found file: " + file_name)
		file_name = dir.get_next()

func create_table():
	pass

#func create_level_db():
	#return
	#var new_level_db: LevelDB = LevelDB.new()
	#new_level_db.levels = get_all_level_data_files()
	#ResourceSaver.save(new_level_db, "res://data_system/level/levelDB/levelDB.tres")
	#ResourceLoader.load("res://data_system/level/levelDB/levelDB.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	#if OS.has_feature("standalone"): EditorInterface.get_resource_filesystem().scan()
	#print("levelDB created and saved in res://data_system/level/levelDB/levelDB.tres")
#
#func create_achivements_db():
	#return
	#var new_ahievement_db: AchievementDB = AchievementDB.new()
	#new_ahievement_db.achievements = get_all_achievement_data_files()
	#ResourceSaver.save(new_ahievement_db, "res://data_system/achievement/achievementDB/achievementDB.tres")
	#ResourceLoader.load("res://data_system/achievement/achievementDB/achievementDB.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	#if OS.has_feature("standalone"): EditorInterface.get_resource_filesystem().scan()
	#print("levelDB created and saved in res://data_system/achievement/achievementDB/achievementDB.tres")
#
#func get_all_level_data_files() -> Array[LevelData]:
	#var level_array: Array[LevelData]
	#var data_folder_path: String = "res://data_system/level/data/"
	#var dir = DirAccess.open(data_folder_path)
	#var files: PackedStringArray
	#if dir: files = dir.get_files()
	#for file in files:
		#var level_ = load(data_folder_path + file)
		#if level_ is LevelData:
			#level_array.append(level_)
	#return level_array
#
#func get_all_achievement_data_files() -> Array[AchievementData]:
	#var achievement_array: Array[AchievementData]
	#var data_folder_path: String = "res://data_system/achievement/data/"
	#var dir = DirAccess.open(data_folder_path)
	#var files: PackedStringArray
	#if dir: files = dir.get_files()
	#for file in files:
		#var achievement_ = load(data_folder_path + file)
		#if achievement_ is AchievementData:
			#achievement_array.append(achievement_)
	#return achievement_array


func _on_close_requested() -> void:
	queue_free()
