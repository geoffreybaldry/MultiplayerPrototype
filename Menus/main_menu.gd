extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enable():
	set_process(true)
	visible = true
	start_button.grab_focus()

func disable():
	visible = false
	set_process(false)

func _on_quit_pressed():
	get_tree().quit()

func _on_start_button_pressed():
	pass # Replace with function body.
