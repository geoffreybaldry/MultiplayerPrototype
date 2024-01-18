extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard):
	actor.idle()
	return SUCCESS

