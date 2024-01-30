extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard):
	var closest_player = actor.get_closest_chasable_player()
	if closest_player:
		blackboard.set_value("closest_player", closest_player)
		return SUCCESS
	
	blackboard.set_value("closest_player", null)
	return FAILURE
