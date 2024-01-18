extends Node

enum game_states {
	STATE_START,
	STATE_OPENING_SCENE,
	STATE_MAIN_MENU,
	STATE_LOBBY_MENU,
	STATE_LOADING,
	STATE_PLAYING,
	STATE_PAUSED,
	STATE_GAME_OVER,
}

# Default Opening Scene when game starts
var game_state = game_states.STATE_START

func change_game_state(new_state):
	var old_state = game_state
	game_state = new_state
	Events.emit_signal("game_state_changed", old_state, new_state)
