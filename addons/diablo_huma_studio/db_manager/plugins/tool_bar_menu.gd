class_name LevelDBCreatorPopupMenu
extends PopupMenu

func _enter_tree() -> void:
	add_item("Open DataBase Manager", 0, KEY_F10)
	id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id_: int):
	if id_ == 0:
		var db_manager_pksc: PackedScene = load("uid://dvf42gydx8g0q")
		var db_manager_window: DBManagerWindow = db_manager_pksc.instantiate()
		EditorInterface.get_base_control().add_child(db_manager_window)
		db_manager_window.popup_centered()
