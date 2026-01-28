class_name LevelDBCreatorPopupMenu
extends PopupMenu

func _enter_tree() -> void:
	add_item("Create MasterDB", 0, KEY_F10)
	id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id_: int):
	if id_ == 0:
		pass
