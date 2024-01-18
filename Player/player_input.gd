extends MultiplayerSynchronizer

@onready var facing_not_updated_timer = $"../Timers/Facing_Not_Updated_Timer"


# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false
@export var fired_primary := false
@export var cycled_weapon_left := false
@export var cycled_weapon_right := false

# Synchronized properties.
@export var direction := Vector2()
@export var facing := Vector2()
@export var ignore_facing := true

const FORTY_FIVE_DEG_RAD = 0.785398

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
	# Connect to signals
	facing_not_updated_timer.timeout.connect(_on_facing_not_updated_timer_timeout)

@rpc("call_local")
func jump():
	jumping = true
	
@rpc("call_local")
func fire_primary():
	fired_primary = true

@rpc("call_local")
func cycle_weapon_left():
	cycled_weapon_left = true
	
@rpc("call_local")
func cycle_weapon_right():
	cycled_weapon_right = true

func _process(delta):
	# Get the input direction and facing from the gamepad
	direction = Focus.input_get_vector("move_left", "move_right", "move_up", "move_down")
	facing = Focus.input_get_vector("look_left", "look_right", "look_up", "look_down")
	
	# Rotate the inputs to allow for the 45degree camera angle
	direction = direction.rotated(-FORTY_FIVE_DEG_RAD)
	facing = facing.rotated(-FORTY_FIVE_DEG_RAD)
	
	check_facing_updated()
	
	# Send jump via rpc
	if Focus.input_is_action_pressed("jump"):
		jump.rpc()
	
	if Focus.input_is_action_pressed("fire_primary"):
		fire_primary.rpc()
		
	if Focus.input_is_action_just_pressed("cycle_weapon_left"):
		cycle_weapon_left.rpc()
		
	if Focus.input_is_action_just_pressed("cycle_weapon_right"):
		cycle_weapon_right.rpc()

func check_facing_updated():
	if facing:
		ignore_facing = false
		facing_not_updated_timer.stop()
	else:
		# Start facing not updated timer, if not already running
		if facing_not_updated_timer.is_stopped() and ignore_facing == false:
			facing_not_updated_timer.start()

func _on_facing_not_updated_timer_timeout():
	ignore_facing = true
