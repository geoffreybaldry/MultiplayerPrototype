extends Node3D

const SPAWN_RANDOM := 5.0

@onready var player_spawn_area = $NavigationRegion3D/PlayerSpawnArea

# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _input(event):
	if event.is_action_pressed("spawn_enemy"):
		Events.emit_signal("spawn")

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	
	# Spawn all the players
	for player_id in Lobby.players:
		var character = preload("res://Player/player.tscn").instantiate()
		# Set the character's player id
		character.player_id = player_id
		
		# Spawn player at random 
		var pos := Vector2.from_angle(randf() * 2 * PI)
		character.position = player_spawn_area.global_position + Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
		$InstantiatedScenes/Players.add_child(character, true)

		# Spawn player at random within player spawner
		# Create a unit Vector2, rotated a random amount
#		var pos := Vector2.from_angle(randf() * 2 * PI)
#		character.position = player_spawn_area.global_position + Vector3(pos.x * SPAWN_RANDOM * randf(), 5.0, pos.y * SPAWN_RANDOM * randf())
#		$Players.add_child(character, true)
