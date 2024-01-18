extends "res://Scenes/Weapons/Pistols/pistol.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Fire in the direction the player is facing, ignoring the weapon's attitude
#func fire(_rotation : Vector3):
#	if cooldown_timer.time_left != 0:
#		return
#
#	#var projectile = Utils.instance_scene_on_main(projectile_scene, muzzle_positon.global_transform)
#	var projectile = projectile_scene.instantiate()
#	projectile.global_transform = muzzle_positon.global_transform
#	get_tree().current_scene.get_node("Projectiles").add_child(projectile, true)
#
#	# Set the projectile's direction based on the passed-in player's rotation
#	projectile.projectile_direction = _rotation.normalized()
#
#	# Set the projectile's speed to that of the weapon's projectile_speed
#	# This way different weapons can give a different speed to similar projectiles
#	projectile.projectile_velocity = projectile_velocity
#
#	cooldown_timer.start()                                                                                                                                                                                                                                                                                                              
