extends ActionLeaf

var target_reached = false

func tick(actor: Node, blackboard: Blackboard):
	if not actor.target_reached.is_connected(_on_target_reached):
		actor.target_reached.connect(_on_target_reached)
	if self.target_reached:
		self.target_reached = false
		actor.target_reached.disconnect(_on_target_reached)
		return SUCCESS
	
	if actor.get_closest_player_in_sight() == null:
		return FAILURE
	
	actor.chase()
	actor.target_position = actor.get_closest_player_in_sight().global_position
	actor.last_known_position = actor.target_position
	actor.has_last_known_position = true
	return RUNNING

func _on_target_reached():
	self.target_reached = true
