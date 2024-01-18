extends Node

var focused := true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true


func input_is_action_pressed(action: StringName) -> bool:
	if focused:
		return Input.is_action_pressed(action)

	return false

# Geoff's addition of Input.is_action_just_pressed()
func input_is_action_just_pressed(action: StringName) -> bool:
	if focused:
		return Input.is_action_just_pressed(action)
	
	return false

# Geoff's addition of Input.get_vector()
func input_get_vector(left, right, up, down) -> Vector2:
	if focused:
		return Input.get_vector(left, right, up, down)
	
	return Vector2.ZERO
	



func event_is_action_pressed(event: InputEvent, action: StringName) -> bool:
	if focused:
		return event.is_action_pressed(action)

	return false
