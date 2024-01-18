# Sound Effects from https://www.fesliyanstudios.com/royalty-free-sound-effects-download

extends "res://Scenes/Enemies/enemy_bi_ped.gd"

@onready var hit_sound = $SoundEffects/HitSound

var blood_splatter_scene = preload("res://Scenes/Weapons/Effects/blood_splatter.tscn")

@rpc("call_local")
func hit(damage:int, _projectile_rotation):
	print("(zombie.gd) Enemy was hit with damage of " + str(damage))
	hit_sound.play()
	
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.rotation.y = _projectile_rotation.y + deg_to_rad(90)
	blood_splatter.position.y = 1.0
	add_child(blood_splatter, true)
	blood_splatter.emitting = true

	health -= damage
