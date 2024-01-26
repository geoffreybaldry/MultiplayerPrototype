extends Node3D

@onready var marker_3d = $Marker3D
@onready var area_3d = $Area3D
@onready var spawn_cool_down_timer = $Timers/SpawnCoolDownTimer

var spawn_ready:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn(entity):
	print("(spawn_point.gd) Spawning entity")
	var instance = Entities.SpawnableEntityScenes[entity].instantiate()
	get_tree().current_scene.get_node("InstantiatedScenes/Enemies").add_child(instance, true)
	instance.global_position = marker_3d.global_position
	spawn_ready = false
	spawn_cool_down_timer.start()

# Check if the spawn point is free of overlapping entities - players or enemies
func is_free():
	return area_3d.get_overlapping_bodies().is_empty() and spawn_ready

func _on_spawn_cool_down_timer_timeout():
	spawn_ready = true
