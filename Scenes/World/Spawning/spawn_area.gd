extends Node3D

@onready var spawn_points = $SpawnPoints

var spawn_point_list
var spawn_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():	
	# Connect to signals
	Events.spawn.connect(_on_spawn)
	
	spawn_point_list = spawn_points.get_children()

#func _process(delta):
#	print("Spawn Queue Count : " + str(spawn_queue.size()))
#	await get_tree().create_timer(3.0).timeout

func _physics_process(delta):
	if spawn_queue.is_empty():
		return

	# Try to spawn an entity from the queue
	var entity = spawn_queue.back()
	var spawn_point = get_free_spawn_point()
	if spawn_point:
		spawn_point.spawn(entity)
		spawn_queue.pop_back()
	
func get_free_spawn_point():
	var candidate_spawn_point_list = spawn_point_list.duplicate()
	candidate_spawn_point_list.shuffle()
	for spawn_point in candidate_spawn_point_list:
		if spawn_point.is_free():
			return spawn_point

func spawn(entity_name):
	# Add the request to spawn to the queue
	spawn_queue.append(entity_name)

func _on_spawn():
	spawn(Entities.SpawnableEntities.ZOMBIE)

func _on_timer_timeout():
	pass
	#spawn(Entities.SpawnableEntities.ZOMBIE)
