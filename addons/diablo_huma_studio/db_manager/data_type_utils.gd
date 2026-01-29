class_name DataTypeUtils
extends RefCounted

const SKIP_PROPERTY_NAMES: Array[String] = [
	"resource_local_to_scene",
	"resource_path",
	"resource_name",
	"resource_scene_unique_id",
	"script",
	"id",
]

static func get_available_data_types() -> Array[Dictionary]:
	var types: Array[Dictionary] = []
	var data_path: String = DBManagerWindow.BRAND_PATH + DBManagerWindow.PLUGIN_FOLDER_NAME + DBManagerWindow.DATA_FOLDER_NAME
	var dir: DirAccess = DirAccess.open(data_path)
	if dir == null:
		return types
	dir.list_dir_begin()
	var folder_name: String = dir.get_next()
	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			var script_path: String = get_script_path(folder_name)
			if ResourceLoader.exists(script_path):
				types.append({
					"class_name": folder_name,
					"script_path": script_path,
				})
		folder_name = dir.get_next()
	return types

static func get_export_properties(resource: Resource) -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for prop in resource.get_property_list():
		if prop.usage & PROPERTY_USAGE_EDITOR and prop.usage & PROPERTY_USAGE_STORAGE:
			if prop.name not in SKIP_PROPERTY_NAMES:
				properties.append(prop)
	return properties

static func get_next_id(type_name: String) -> int:
	var data_folder: String = get_data_folder_path(type_name)
	var dir: DirAccess = DirAccess.open(data_folder)
	if dir == null:
		return 1
	var max_id: int = 0
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(data_folder + file_name)
			if res != null and "id" in res:
				max_id = max(max_id, res.id)
		file_name = dir.get_next()
	return max_id + 1

static func get_data_folder_path(type_name: String) -> String:
	return DBManagerWindow.BRAND_PATH + DBManagerWindow.PLUGIN_FOLDER_NAME + DBManagerWindow.DATA_FOLDER_NAME + type_name + "/"

static func data_exists(type_name: String, data_name: String) -> bool:
	var data_folder: String = get_data_folder_path(type_name)
	var file_name: String = DataTypeGenerator._to_snake_case(type_name) + "_" + str(data_name) + ".tres"
	return FileAccess.file_exists(data_folder + file_name)

static func get_script_path(type_name: String) -> String:
	return DBManagerWindow.BRAND_PATH + DBManagerWindow.PLUGIN_FOLDER_NAME + DBManagerWindow.DATA_TYPES_FOLDER_NAME + DataTypeGenerator._to_snake_case(type_name) + ".gd"
