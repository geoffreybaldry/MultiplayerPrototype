extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard):
	if actor.get_players_in_chase_range():
		return SUCCESS
	else:
		return FAILURE

