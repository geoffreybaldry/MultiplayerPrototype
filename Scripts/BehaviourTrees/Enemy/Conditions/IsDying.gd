extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard):
	if actor.is_dying():
		return SUCCESS
	else:
		return FAILURE

