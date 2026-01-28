extends Node

func _init() -> void:
	if not OS.has_feature("standalone"):
		pass
		print("level db created from singleton at standalone Run F5 or F6")
