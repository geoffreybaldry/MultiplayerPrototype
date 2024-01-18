extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard):
	if actor._has_last_known_position():
		return SUCCESS
	else:
		return FAILURE

