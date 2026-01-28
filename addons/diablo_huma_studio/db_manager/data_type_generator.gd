class_name DataTypeGenerator
extends RefCounted

static func generate(type_name: String, properties: Array[Dictionary]) -> Error:
	var err: Error = _generate_data_type_file(type_name, properties)
	if err != OK: return err
	err = _generate_data_folder(type_name)
	if err != OK: return err
	return OK

static func _generate_data_folder(type_name: String) -> Error:
	var dir: DirAccess = DirAccess.open(DBManagerWindow.BRAND_PATH + DBManagerWindow.PLUGIN_FOLDER_NAME + DBManagerWindow.DATA_FOLDER_NAME)
	var err: Error = dir.make_dir(type_name)
	if err != OK: return err

	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()

	return OK

static func _generate_data_type_script_text(type_name: String, properties: Array[Dictionary]) -> String:
	var script_text: String = ""
	script_text += "class_name " + type_name + "\n"
	script_text += "extends DataType\n"

	if not properties.is_empty():
		script_text += "\n"
	for prop in properties:
		script_text += "@export var " + prop["name"] + ": " + prop["type"] + "\n"

	return script_text

static func _generate_data_type_file(type_name: String, properties: Array[Dictionary]) -> Error:
	var script_text: String = _generate_data_type_script_text(type_name, properties)
	var path: String = _get_data_types_path()
	var file_name: String = _to_snake_case(type_name) + ".gd"
	if ResourceLoader.exists(path + file_name): return Error.ERR_ALREADY_EXISTS
	var file := FileAccess.open(path + file_name, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(script_text)
	file.close()
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()

	return OK

static func _get_data_types_path() -> String:
	return DBManagerWindow.BRAND_PATH + DBManagerWindow.PLUGIN_FOLDER_NAME + DBManagerWindow.DATA_TYPES_FOLDER_NAME

static func _to_snake_case(text: String) -> String:
	var result: String = ""
	for i in text.length():
		var c: String = text[i]
		if c == c.to_upper() and c != c.to_lower() and i > 0:
			result += "_"
		result += c.to_lower()
	return result
