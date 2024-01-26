extends CPUParticles3D

func _on_timer_timeout():
	print("Freeing Blood Splatter on peer " + str(multiplayer.get_unique_id()))
	queue_free()
