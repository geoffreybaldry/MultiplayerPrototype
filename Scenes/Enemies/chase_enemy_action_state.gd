class_name ChaseEnemyActionState
extends EnemyActionState

func Enter():
	print("Entered Chase State")
	super()
	
func Exit():
	print("Exiting Chase State")
	super()
	# Remove navigation path
	#navigation_agent_3d.set_target_position(actor.global_position)

func Update(_delta):
	super(_delta)
	state_label.text = "Chase"
	
 
func Physics_update(_delta):
	super(_delta)

	# If a player is in attack range, attack.
	if players_in_attack_range:
		transitioned.emit("AttackEnemyActionState")

	# Move the enemy along the navigation path
	move_on_path(_delta)

func move_on_path(_delta):

	if closest_player_in_sight:
		last_known_position = closest_player_in_sight.global_position
		update_target_position(last_known_position)
	
		# Get the next position in the path
		next_position = navigation_agent_3d.get_next_path_position()
		print("Got new path position " + str(next_position))
	
		# Get normalized vector to next position 
		var new_velocity = (next_position - actor.global_position).normalized() * RUN_SPEED
		actor.velocity = actor.velocity.move_toward(new_velocity, 0.2)
	else:#
		# Get the next position in the path
		next_position = navigation_agent_3d.get_next_path_position()

		# Get normalized vector to next position 
		var new_velocity = (next_position - actor.global_position).normalized() * RUN_SPEED
		actor.velocity = actor.velocity.move_toward(new_velocity, 0.2)

	if navigation_agent_3d.is_navigation_finished():
		print("Navigation Finished")
		transitioned.emit("IdleEnemyActionState")

	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(actor.velocity.x, actor.velocity.z), ANGULAR_ACCELERATION * _delta)
	animation_player.play("Library_Zombie/Zombie_Run")
	actor.move_and_slide()


func update_target_position(target_position):
	navigation_agent_3d.set_target_position(target_position)
