extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard):
	if actor.get_closest_player_in_sight():
		return SUCCESS
	else:
		return FAILURE

