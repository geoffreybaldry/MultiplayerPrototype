extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard):
	actor.die()
	return SUCCESS

