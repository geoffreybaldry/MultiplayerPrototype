extends Control

@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var start_button = $StartButton
@onready var disconnect_button = $DisconnectButton
@onready var name_edit = $NameEdit

@onready var player_list = $VBoxContainer/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to signals
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.player_disconnected.connect(_on_player_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enable():
	set_process(true)
	visible = true
	host_button.grab_focus()

func disable():
	visible = false
	set_process(false)


func _on_host_button_pressed():
	host_button.disabled = true
	join_button.disabled = true
	host_button.hide()
	join_button.hide()
	name_edit.editable = false
	disconnect_button.show()
	
	Lobby.create_game()


func _on_join_button_pressed():
	host_button.disabled = true
	join_button.disabled = true
	host_button.hide()
	join_button.hide()
	name_edit.editable = false
	disconnect_button.show()
	
	Lobby.join_game()


func _on_start_button_pressed():
	Lobby.load_game.rpc("res://Scenes/game.tscn")
	pass # Replace with function body.


func _on_name_text_changed(new_text):
	Lobby.player_info.name = new_text


func _on_disconnect_button_pressed():
	host_button.disabled = false
	join_button.disabled = false
	host_button.show()
	join_button.show()
	name_edit.editable = true
	disconnect_button.hide()
	
	# Clear the player_list
	player_list.clear()
	
	# disable the start_button
	start_button.disabled = true
	start_button.visible = false
	
	# No longer receive multiplayer signals once set to null
	multiplayer.multiplayer_peer = null
	

func remove_player_from_list(peer_id):
	for idx in range(player_list.get_item_count()):
		if player_list.get_item_metadata(idx) == peer_id:
			player_list.remove_item(idx)
			break


func _on_player_connected(peer_id, player_info):
	var idx = player_list.add_item(player_info.name, null, false)
	player_list.set_item_metadata(idx, peer_id)
	
	# If the connecting player was the server, then make the start_game button available
	if peer_id == 1 and multiplayer.is_server():
		start_button.disabled = false
		start_button.visible = true
	
	
func _on_player_disconnected(peer_id):
	print("(lobby_menu.gd) Player disconnected with peer_id " + str(peer_id))
	remove_player_from_list(peer_id)

