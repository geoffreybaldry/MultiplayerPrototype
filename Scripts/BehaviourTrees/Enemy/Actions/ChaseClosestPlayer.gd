extends ActionLeaf

var target_reached = false

func tick(actor: Node, blackboard: Blackboard):
	if not actor.target_reached.is_connected(_on_target_reached):
		actor.target_reached.connect(_on_target_reached)
	if self.target_reached:
		self.target_reached = false
		actor.target_reached.disconnect(_on_target_reached)
		return SUCCESS
	
	var closest_player = actor.get_closest_chasable_player()
	if closest_player:
		actor.target_position = closest_player.global_position
		actor.chase()
		return RUNNING
	
	return FAILURE

func _on_target_reached():
	self.target_reached = true
