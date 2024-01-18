extends Node

@onready var main_menu = $MainMenu
@onready var lobby_menu = $LobbyMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect signals
	Events.game_state_changed.connect(_on_game_state_changed)
	
	# Start the game at the lobby menu
	GameStates.change_game_state(GameStates.game_states.STATE_LOBBY_MENU)

func _on_game_state_changed(old_state, new_state):
	print("(world.gd) detected game_state change from " + GameStates.game_states.keys()[old_state] + " to " + GameStates.game_states.keys()[new_state])
		
	match new_state:
		GameStates.game_states.STATE_MAIN_MENU:
			main_menu.enable()
			get_tree().paused = false
		GameStates.game_states.STATE_LOBBY_MENU:
			lobby_menu.enable()
			get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
