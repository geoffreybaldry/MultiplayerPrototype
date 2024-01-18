class_name SpawnEnemyActionState
extends EnemyActionState
 
func Enter():
	print("Entering Spawn State")
	super()
	
func Exit():
	super()
	print("Exiting Spawn State")

func Update(_delta):
	super(_delta)
	state_label.text = "Spawn"
 
func Physics_update(_delta):
	super(_delta)

	# If a player is in attack range, attack.
#	if players_in_attack_range:
#		transitioned.emit("AttackEnemyActionState")
#	# If we have a visible player, move to chase state.
#	elif closest_player_in_sight:
#		transitioned.emit("ChaseEnemyActionState")
#	else:
#		animation_player.play("Library_Zombie/Zombie_Idle")
#		actor.velocity = actor.velocity.move_toward(Vector3.ZERO, 0.2)
#
#	actor.move_and_slide()

