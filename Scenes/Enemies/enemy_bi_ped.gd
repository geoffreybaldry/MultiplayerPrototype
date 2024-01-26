extends CharacterBody3D

signal target_reached

enum AnimationState {
	IDLE = 0,
	RUN = 1,
	ATTACK = 2,
	END_CHASE = 3,
	DYING = 4,
}

var AnimationNames = {
	AnimationState.IDLE:"Library_Zombie/Zombie_Idle",
	AnimationState.RUN:"Library_Zombie/Zombie_Run",
	AnimationState.ATTACK:"Library_Zombie/Zombie_Attack",
	AnimationState.END_CHASE:"Library_Zombie/Zombie_Run",
	AnimationState.DYING:"Library_Zombie/Zombie_Death_Backward",
}

var AnimationSpeedScales = {
	AnimationState.IDLE:1.0,
	AnimationState.RUN:1.0,
	AnimationState.ATTACK:2.0,
	AnimationState.END_CHASE:1.0,
	AnimationState.DYING:1.0,
}

const SIGHT_RAY_LENGTH = 5.0
const RUN_SPEED = 3.0
const ANGULAR_ACCELERATION = 10.0

@export var animation_player: AnimationPlayer
@export var max_health:float

@onready var visual = $Visual
@onready var hitbox = $Visual/Hitbox
@onready var state_label = $Visual/StateLabel
@onready var closest_player_in_sight_label = $Visual/ClosestPlayerInSightLabel
@onready var health_bar_3d = $Visual/HealthBar3D
@onready var marker_3d = $Detector/Marker3D
@onready var ray_cast_3d = $Detector/RayCast3D
@onready var player_detector = $Detector/PlayerDetector
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var beehave_tree = $BehaviourTrees/BeehaveTree
@onready var hurtbox_collision_shape = $Hurtbox/HurtboxCollisionShape3D

var state = AnimationState.IDLE: set = _set_state
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var players_in_attack_range = []
var players_in_chase_range = []
var closest_player_in_sight = null: set = _set_closest_player_in_sight
var target_position: Vector3: set = _set_target_position
var last_known_position: Vector3
var has_last_known_position:bool = false
var health:float : set = _set_health
var dying:bool = false : set = _set_dying

func _ready():
	#set_physics_process(multiplayer.is_server())
	#set_process(multiplayer.is_server())
	
	# Disable the behaviour tree on clients - we only want it active on the server
	#beehave_tree.enabled = false
	beehave_tree.enabled = multiplayer.is_server()
	
	# State and Position
	state = AnimationState.IDLE
	target_position = global_position
	
	# Vitals
	health_bar_3d.init_health(max_health)
	health = max_health
	

func _physics_process(_delta):
	# The multiplayer server performs all calculations
	if multiplayer.is_server():

		# Apply Gravity
		apply_gravity(_delta)
		
		check_players_in_attack_range()
		check_players_in_chase_range()
		check_players_in_sight()
		
		match state:
			AnimationState.IDLE, AnimationState.ATTACK, AnimationState.DYING:
				velocity = velocity.move_toward(Vector3.ZERO, 0.2)
			AnimationState.RUN, AnimationState.END_CHASE:
				# Move to target location
				move_on_path()
				# Face direction of travel
				face_direction(_delta)
			_:
				pass

		# Clamp calculated velocity to ensure knock backs, etc don't accumulate
		velocity = velocity.clamp(-Vector3.ONE * RUN_SPEED, Vector3.ONE * RUN_SPEED)
		move_and_slide()
	
	play_animation()
	
func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

func check_players_in_attack_range():
	players_in_attack_range = hitbox.get_overlapping_areas()
	
func get_players_in_attack_range():
	return players_in_attack_range

func check_players_in_chase_range():
	players_in_chase_range = player_detector.get_overlapping_bodies()
	
func get_players_in_chase_range():
	return players_in_chase_range
	
func check_players_in_sight():
	if not players_in_chase_range:
		closest_player_in_sight = null
		return
	
	# If there are some players in chase range, then check which ones we have line of sight to
	var closest_player_distance = -1
	closest_player_in_sight = null
	var space_state = get_world_3d().direct_space_state
	var origin = marker_3d.global_position
	# The mask should match the "value" of the layer that you want to collide with
	var mask = 0b101 # 0bxxx identifies the remainder as binary.
	for player in players_in_chase_range:
		var end = origin + origin.direction_to(player.global_position + Vector3(0.0, 1.0, 0.0)) * SIGHT_RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
		query.collide_with_areas = false
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		
		# If we hit something, result will be non-empty dictionary
		if result:
			# Check to see if we collided with a player
			if result.collider.is_in_group("Player"):
				# Get the distance to the collision point so we can see if it's closest
				var distance = origin.distance_to(result.position)
				if closest_player_distance == -1 or distance < closest_player_distance:
					closest_player_distance = distance
					closest_player_in_sight = player
					# Point the raycast at the closest player - just a useful debug visualisation
					ray_cast_3d.set_target_position(ray_cast_3d.to_local(end))
					
	
	
func get_closest_player_in_sight():
	return closest_player_in_sight
	

func attack():
	# During the attack animation, the enemy will execute a script to check if the player is in attack range still
	# If so, the enemy will inflict damage on the player
	state = AnimationState.ATTACK
	
func idle():
	state = AnimationState.IDLE
	
func chase():
	state = AnimationState.RUN
	
func end_chase():
	state = AnimationState.END_CHASE
	
func die():
	state = AnimationState.DYING

# This function is called from the Attack animation at the point where the enemy's attack would contact the player
func perform_attack():
	if not multiplayer.is_server():
		return
		
	# Check that the player we are attacking is still within attack range
	var overlapping_areas = hitbox.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("Player"):
			# Inflict damage!
			if area.get_parent().has_method("hit"):
				area.get_parent().hit.rpc()
				break

func _set_target_position(tl):
	target_position = tl
	if navigation_agent_3d != null:
		navigation_agent_3d.set_target_position(target_position)
		
func _has_last_known_position():
	return has_last_known_position
		
func _set_state(new_state):
	state = new_state
	state_label.text = AnimationState.keys()[state]
	
func _set_closest_player_in_sight(player):
	closest_player_in_sight = player
	if closest_player_in_sight:
		closest_player_in_sight_label.text = closest_player_in_sight.name
	else:
		closest_player_in_sight_label.text = "null"
	

func move_on_path():
	var next_position = navigation_agent_3d.get_next_path_position()
	
	# Get normalized vector to next position 
	var new_velocity = (next_position - global_position).normalized() * RUN_SPEED
	velocity = velocity.move_toward(new_velocity, 0.2)

# Face the direction of travel, or the player if chasing
func face_direction(_delta):
	if closest_player_in_sight:
		var player_vec = global_position.direction_to(closest_player_in_sight.global_position)
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(player_vec.x, player_vec.z), ANGULAR_ACCELERATION * _delta)
	else:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(velocity.x, velocity.z), ANGULAR_ACCELERATION * _delta)

func play_animation():
	animation_player.speed_scale = AnimationSpeedScales[state]
	animation_player.play(AnimationNames[state])

func hit(damage:int, _projectile_velocity:Vector3):
	print("(enemy_bi_ped.gd) Enemy was hit with damage of " + str(damage))
	
func is_dying():
	return dying

func _set_health(new_health):
	health = new_health
	health_bar_3d._set_health(health)
	
	if health <= 0:
		dying = true

func _set_dying(value):
	dying = value
	hurtbox_collision_shape.set_deferred("disabled", true)
	# Turn off enemy's collision shape layer and player mask so player can pass through
	set_collision_layer_value(6, false)
	set_collision_mask_value(1, false)
	
func _on_navigation_agent_3d_target_reached():
	emit_signal("target_reached")

func delete_enemy():
	if not multiplayer.is_server():
		return
	# Remove the object after 'x' seconds
	await get_tree().create_timer(3.0).timeout
	#free_enemy.rpc()
	queue_free()
	
#@rpc("call_local")
#func free_enemy():
#queue_free()
