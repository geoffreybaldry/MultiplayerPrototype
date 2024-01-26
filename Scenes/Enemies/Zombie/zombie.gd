# Sound Effects from https://www.fesliyanstudios.com/royalty-free-sound-effects-download

extends "res://Scenes/Enemies/enemy_bi_ped.gd"

var blood_splatter_scene = preload("res://Scenes/Weapons/Effects/blood_splatter.tscn")

func hit(damage:int, _projectile_velocity:Vector3):
	super(damage,_projectile_velocity)

	# Create Blood Splatter
	create_blood_splatter.rpc(_projectile_velocity)

	# Reduce Health
	health -= damage
	
	# Knock-back/slow-down - can't be knocked back if attacking
	if state != AnimationState.ATTACK:
		var knock_back_vec = _projectile_velocity.normalized() * 2.0
		velocity += knock_back_vec

@rpc("call_local")
func create_blood_splatter(_projectile_velocity):
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.rotation.y = atan2(_projectile_velocity.x, _projectile_velocity.z)
	blood_splatter.position.y = 1.0
	add_child(blood_splatter, true)
	blood_splatter.emitting = true
