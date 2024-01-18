extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard):
	actor.attack()
	return SUCCESS

