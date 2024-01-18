extends CharacterBody3D

const WALK_SPEED = 4.0
const RUN_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const ANGULAR_ACCELERATION = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player = $Visual/YBot_Locomotion/AnimationPlayer
@onready var animation_tree = $Visual/YBot_Locomotion/AnimationTree
@export var animation_locomotion_blend_position := Vector2.ZERO
@export var target_animation_locomotion_blend_position := Vector2.ZERO

@onready var visual = $Visual

# UI elements
@onready var player_info = $Visual/PlayerInfo

# Player synchronized input.
@onready var input = $PlayerInputSynchronizer

# Synchronized values
var direction : Vector3 
var facing : Vector3

enum WEAPON_NAMES {
	BLASTER_A,
	BLASTER_B,
	BLASTER_E
}

const WEAPON_TYPES = {
	"BLASTER_A" : "PISTOL",
	"BLASTER_B" : "PISTOL",
	"BLASTER_E" : "RIFLE"
}

@onready var WEAPONS = {
	"PISTOL" : {
		"BLASTER_A" : $Visual/YBot_Locomotion/Armature/GeneralSkeleton/PistolAttachment/Pistols/BLASTER_A,
		"BLASTER_B" : $Visual/YBot_Locomotion/Armature/GeneralSkeleton/PistolAttachment/Pistols/BLASTER_B
	},
	"RIFLE" : {
		"BLASTER_E" : $Visual/YBot_Locomotion/Armature/GeneralSkeleton/RifleAttachment/Rifles/BLASTER_E,
	}
}

var player_weapons = [false, false, false]

@onready var current_weapon_instance

@export var current_weapon_id : int = -1 :
	set(new_weapon_id):
		if current_weapon_id != -1:
			current_weapon_instance.hide()
		switch_to_weapon(new_weapon_id)
		current_weapon_id = new_weapon_id
		
# Set by the authority, synchronized on spawn.
@export var player_id := 1 :
	set(id):
		player_id = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInputSynchronizer.set_multiplayer_authority(player_id)

func _ready():
	# Set the camera as current if we are this player.
	if player_id == multiplayer.get_unique_id():
		$Camera3D.current = true
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	#set_physics_process(multiplayer.is_server())
	set_process(multiplayer.is_server())
	
	# Give player BLASTER_A
	pickup_weapon(WEAPON_NAMES.BLASTER_A)
	pickup_weapon(WEAPON_NAMES.BLASTER_B)
	pickup_weapon(WEAPON_NAMES.BLASTER_E)

func _process(delta):
	#player_info.text = str(animation_locomotion_blend_position) + " " + str(target_animation_locomotion_blend_position)
	player_info.text = str(facing)
	
	# Handle if the primary weapon fired
	handle_fire_primary()
	
	# Handle if cycle_weapon_left selected
	handle_cycle_weapon_left()
	
	# Handle if cycle_weapon_right selected
	handle_cycle_weapon_right()

func _physics_process(delta):
	# The multiplayer server performs all calculations
	if multiplayer.is_server():
		# Add the gravity.
		apply_gravity(delta)

		# Handle Jump.
		handle_jump()

		# Apply Input Direction
		apply_input_direction(delta)
		
		# Apply Input Facing
		apply_input_facing(delta)
				
		# Calculate how to set the animation tree
		calculate_animation_tree()
		
		# Apply calculated animation to tree
		apply_animation_tree()

		# Move
		move_and_slide()
	else:
		# Multiplayer clients only update the character's animation. Everything else is replicated
		# Apply calculated animation to tree
		apply_animation_tree()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
func handle_jump():
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Reset jump state.
	input.jumping = false

func handle_fire_primary():
	# Fire primary weapon
	if input.fired_primary:
		current_weapon_instance.fire(player_id)
		
	input.fired_primary = false
	
	

func pickup_weapon(weapon_id):
	# Pick up weapon if we don't already have it
	if not player_weapons[weapon_id]:
		player_weapons[weapon_id] = true
		# Auto-switch to picked up weapon
		current_weapon_id = weapon_id
	
func switch_to_weapon(new_weapon_id):
	# Show the new weapon
	current_weapon_instance = WEAPONS[get_weapon_type(new_weapon_id)][WEAPON_NAMES.keys()[new_weapon_id]]
	current_weapon_instance.show()
	
	# Change animation state (player stance) to match weapon type
	animation_tree.set("parameters/Transition/transition_request", get_weapon_type(new_weapon_id))
	
func get_weapon_type(weapon_id):
	return WEAPON_TYPES[WEAPON_NAMES.keys()[weapon_id]]

func handle_cycle_weapon_left():
	# Cycle weapon left
	if input.cycled_weapon_left:
		print("Handling cycle left")
		
		var new_weapon_id = current_weapon_id - 1
		while new_weapon_id >= 0:
			print("Current Weapon : " + str(current_weapon_id) + " Checking for weapon : " + str(new_weapon_id))
			if player_weapons[new_weapon_id]:
				current_weapon_id = new_weapon_id
				break
			new_weapon_id -= 1
				
	input.cycled_weapon_left = false
	
func handle_cycle_weapon_right():
	# Cycle weapon right
	if input.cycled_weapon_right:
		print("Handling cycle right")
		var new_weapon_id = current_weapon_id + 1
		while new_weapon_id < player_weapons.size():
			print("Current Weapon : " + str(current_weapon_id) + " Checking for weapon : " + str(new_weapon_id))
			if player_weapons[new_weapon_id]:
				current_weapon_id = new_weapon_id
				break
			new_weapon_id += 1
			
	input.cycled_weapon_right = false

func apply_input_direction(delta):
	# Get the (synchronized) input direction and handle the movement/deceleration.
	direction = calculate_direction_normalized()
	
	if direction:
		if input.direction.length() < 0.7:
			velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, WALK_SPEED)
			velocity.z = move_toward(velocity.z, direction.z * WALK_SPEED, WALK_SPEED)

		else:
			velocity.x = move_toward(velocity.x, direction.x * RUN_SPEED, RUN_SPEED)
			velocity.z = move_toward(velocity.z, direction.z * RUN_SPEED, RUN_SPEED)
	else:
		# Simulate friction slowing player down
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED / 2)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED / 2)

func apply_input_facing(delta):
	# Get the (synchronized) input facing.
	facing = calculate_facing_normalized()
	direction = calculate_direction_normalized()
	
	# If facing not updated for a while, it should be ignored in favour of direction
	if direction and input.ignore_facing:
		# If no input from the facing vector, let the player turn towards direction vector
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(direction.x, direction.z), ANGULAR_ACCELERATION * delta)
	elif facing:
		# Turn the player's visual node smoothly using ANGULAR_ACCELERATION towards facing vector
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(facing.x, facing.z), ANGULAR_ACCELERATION * delta)

func calculate_direction_normalized():
	return transform.basis * Vector3(input.direction.x, 0, input.direction.y).normalized()
	
func calculate_facing_normalized():
	return transform.basis * Vector3(input.facing.x, 0, input.facing.y).normalized()
	
func calculate_animation_tree():
	if not input.direction:
		# Idle
		target_animation_locomotion_blend_position = Vector2.ZERO
	else:
		if not input.facing:
			# Move Forwards (no "facing" over-ride)
			target_animation_locomotion_blend_position = Vector2.DOWN
		else:
			# Facing over-ride, so face in direction of "facing"
			# Find the angle between the direction and facing, to decide upon locomotion animation
			var angle_rad = input.direction.angle_to(input.facing)
			var angle_deg = rad_to_deg(angle_rad)

			# Find the direction for the animation
			if angle_deg > -45 and angle_deg < 45:
				target_animation_locomotion_blend_position = Vector2.DOWN
			elif angle_deg <= -45 and angle_deg >= -135:
				target_animation_locomotion_blend_position = Vector2.RIGHT
			elif angle_deg < -135 or angle_deg > 135:
				target_animation_locomotion_blend_position = Vector2.UP
			else:
				target_animation_locomotion_blend_position = Vector2.LEFT
				
	# Gradually interpolate the actual blend position towards the target position
	animation_locomotion_blend_position = animation_locomotion_blend_position.lerp(target_animation_locomotion_blend_position, 0.2)

func apply_animation_tree():
	# Set locomotion blends
	animation_tree.set("parameters/Unarmed_Run/blend_position", animation_locomotion_blend_position)
	animation_tree.set("parameters/Pistol_Run/blend_position", animation_locomotion_blend_position)
	animation_tree.set("parameters/Rifle_Run/blend_position", animation_locomotion_blend_position)

@rpc("call_local")
func hit():
	print("Player" + str(player_id) + " was hit")
