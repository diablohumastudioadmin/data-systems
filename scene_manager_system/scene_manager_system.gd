@tool
extends Node

func change_scene(new_packed_scene: PackedScene, arguments: Dictionary = {}, current_scene: Node = get_tree().current_scene, is_same_name: bool = false) -> void:
	var new_scene: Node 
	
	assert(new_packed_scene.can_instantiate())
	new_scene = new_packed_scene.instantiate()

	for key in arguments:
		if key in new_scene:
			new_scene[key] = arguments[key]
	# If you want to run something with the arguments (or even without them) between _init() and _ready() here is the place. 
	# Just add this function to the scene to change to 
	if new_scene.has_method("_sms_initialize"): new_scene._sms_initialize()

	if is_same_name:
		var current_scene_name: String = current_scene.name
		current_scene.name = "OldScene"
		new_scene.name = current_scene_name

	var old_scene_index_in_parent : int= current_scene.get_index()
	current_scene.get_parent().add_child(new_scene)
	new_scene.get_parent().move_child(new_scene, old_scene_index_in_parent)
	
	if current_scene.is_unique_name_in_owner(): 
		new_scene.unique_name_in_owner = true
	
	if current_scene == get_tree().current_scene: get_tree().current_scene = new_scene
	current_scene.queue_free()
