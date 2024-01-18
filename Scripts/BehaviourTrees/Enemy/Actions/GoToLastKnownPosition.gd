extends ActionLeaf

var target_reached = false

func tick(actor: Node, blackboard: Blackboard):
	if not actor.target_reached.is_connected(_on_target_reached):
		actor.target_reached.connect(_on_target_reached)
	if self.target_reached:
		self.target_reached = false
		actor.target_reached.disconnect(_on_target_reached)
		actor.has_last_known_position = false
		return SUCCESS
		
	actor.end_chase()
	#actor.target_position = actor.last_known_position
	return RUNNING

func _on_target_reached():
	self.target_reached = true
