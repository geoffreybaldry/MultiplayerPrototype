class_name DeathEnemyActionState
extends EnemyActionState
 
func Enter():
	print("Entered Death State")
	super()
	
func Exit():
	super()
	print("Exited Death State")

func Update(_delta):
	super(_delta)
	state_label.text = "Death"
 
func Physics_update(_delta):
	super(_delta)
	
	animation_player.play("Library_Zombie/Zombie_Death_Forward")
	
	#actor.queue_free()
