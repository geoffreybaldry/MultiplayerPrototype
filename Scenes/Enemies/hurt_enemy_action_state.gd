class_name HurtEnemyActionState
extends EnemyActionState
 
func Enter():
	print("Entered Hurt State")
	super()
	
func Exit():
	super()
	print("Exiting Hurt State")

func Update(_delta):
	super(_delta)
	state_label.text = "Hurt"
 
func Physics_update(_delta):
	super(_delta)
	
	animation_player.play("Library_Zombie/Zombie_Death_Backward")
	
	# If we have a visible player, move to chase state
	if closest_player_in_sight:
		transitioned.emit("ChaseEnemyActionState")
	else:
		transitioned.emit("IdleEnemyActionState")
