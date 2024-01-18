extends Node

#func instance_scene_on_main(scene, position):
#	var main = get_tree().current_scene
#	var instance = scene.instantiate()
#	main.add_child(instance)
#	instance.global_position = position
#
#	return instance
	
func instance_scene_on_main(scene, transform):
	var main = get_tree().current_scene
	var instance = scene.instantiate()
	# True enfirces that instantiated nodes have a readable name in scene tree
	main.add_child(instance, true)
	instance.global_transform = transform
	
	return instance
