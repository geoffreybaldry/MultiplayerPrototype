class_name AttackEnemyActionState
extends EnemyActionState

func Enter():
	print("Entered Attack State")
	super()
	animation_player.speed_scale = 2.0
	
func Exit():
	print("Exiting Attack State")
	super()
	animation_player.speed_scale = 1.0
	
func Update(_delta):
	super(_delta)
	state_label.text = "Attack"

func Physics_update(_delta):
	super(_delta)
	
	# Face towards and attack the closest player if they are in attack range
	if players_in_attack_range and closest_player_in_sight:
		var angle_to_player = atan2(closest_player_in_sight.global_position.x - actor.global_position.x, closest_player_in_sight.global_position.z - actor.global_position.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, angle_to_player, ANGULAR_ACCELERATION * _delta)
		
		# During the attack animation, the player will execute a script to check if the player is in attack range still
		# If so, the enemy will inflict damage on the player
		animation_player.play("Library_Zombie/Zombie_Attack")
	elif players_in_chase_range:
		transitioned.emit("ChaseEnemyActionState")
	else:
		transitioned.emit("IdleEnemyActionState")
	
	actor.velocity = actor.velocity.move_toward(Vector3.ZERO, 0.2)
	actor.move_and_slide()

# This function is called from the Attack animation at the point where the enemy's attack would contact the player
func perform_attack():
	# Check that the player we are attacking is still within attack range
	var overlapping_areas = hitbox.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("Player"):
			# Inflict damage!
			if area.get_parent().has_method("hit"):
				area.get_parent().hit.rpc()
				break


func _on_animation_player_animation_finished(_anim_name):
	transitioned.emit("ChaseEnemyActionState")
