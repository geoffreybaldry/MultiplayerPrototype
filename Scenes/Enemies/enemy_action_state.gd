# https://www.sandromaglione.com/articles/how-to-implement-state-machine-pattern-in-godot

class_name EnemyActionState
extends State

const RAY_LENGTH = 5.0
const RUN_SPEED = 3.0
const ANGULAR_ACCELERATION = 10.0

@export var actor: CharacterBody3D
@export var animation_player: AnimationPlayer

@onready var visual = $"../../../Visual"
@onready var state_label = $"../../../Visual/State"
@onready var closest_player_label = $"../../../Visual/ClosestPlayerInSight"
@onready var marker_3d = $"../../../Detector/Marker3D"
@onready var ray_cast_3d = $"../../../Detector/RayCast3D"
@onready var player_detector = $"../../../Detector/Area3D"

# Navigation
@onready var navigation_agent_3d = $"../../../NavigationAgent3D"

# Combat
@onready var hitbox = $"../../../Visual/Hitbox"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var players_in_attack_range = []
var players_in_chase_range = []
var closest_player_in_sight = null

# Navigation
var next_position: Vector3
var last_known_position: Vector3

func Enter():
	pass
	
func Exit():
	pass

func Update(_delta):
	if closest_player_in_sight:
		closest_player_label.text = closest_player_in_sight.name
	else:
		closest_player_label.text = "null"

func Physics_update(_delta):
	pass
	# Apply Gravity
	apply_gravity(_delta)
	
	# Check for players in attack range
	check_players_to_attack()
	
	# Check for players to chase
	check_players_to_chase()

func apply_gravity(delta):
	# Add the gravity.
	if not actor.is_on_floor():
		actor.velocity.y -= gravity * delta

func check_players_to_attack():
	players_in_attack_range = hitbox.get_overlapping_areas()
	
	# If a player is in attack range, attack.
#	if players_in_attack_range:
#		transitioned.emit("AttackEnemyActionState")

# Check for players within range that the enemy will chase until they are in attack range
func check_players_to_chase():
	players_in_chase_range = player_detector.get_overlapping_bodies()
	closest_player_in_sight = null
	var closest_player_distance = -1
	
	if not players_in_chase_range:
		return

	# If there are some players in range, then check which ones we have line of sight to
	var space_state = actor.get_world_3d().direct_space_state
	var origin = marker_3d.global_position
	for player in players_in_chase_range:
		var end = origin + origin.direction_to(player.global_position + Vector3(0.0, 1.0, 0.0)) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
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
					
#	if closest_player_in_sight:
#		transitioned.emit("ChaseEnemyActionState")
