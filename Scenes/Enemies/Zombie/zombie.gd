# Sound Effects from https://www.fesliyanstudios.com/royalty-free-sound-effects-download

extends "res://Scenes/Enemies/enemy_bi_ped.gd"

var blood_splatter_scene = preload("res://Scenes/Weapons/Effects/blood_splatter.tscn")

@rpc("call_local")
func hit(damage:int, _projectile_velocity:Vector3):
	super(damage,_projectile_velocity)
	
	# Create Blood Splatter
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.rotation.y = atan2(_projectile_velocity.x, _projectile_velocity.z) - deg_to_rad(90)
	blood_splatter.position.y = 1.0
	add_child(blood_splatter, true)
	blood_splatter.emitting = true

	# Reduce Health
	health -= damage
	
	# Knock-back/slow-down
	var knock_back_vec = _projectile_velocity.normalized() * 2.0
	velocity += knock_back_vec
