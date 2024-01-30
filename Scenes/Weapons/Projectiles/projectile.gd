extends CharacterBody3D

const DIRECTION_RAY_LENGTH = 7.0
const BOUNCE_RAY_LENGTH = 4.0
const NORMAL_RAY_LENGTH = 5.0

@export var projectile_velocity : float
@export var player_id : int
@export var damage : int
@export var hit_enemy_sound:AudioStreamPlayer

@onready var projectile_collision_shape = $ProjectileCollisionShape3D
@onready var hitbox_collision_shape = $Hitbox/HitboxCollisionShape3D
@onready var time_to_live_timer = $Timers/TimeToLiveTimer
@onready var effect_wait_timer = $Timers/EffectWaitTimer

@onready var direction_ray = $Visual/DirectionRay
@onready var reflection_ray = $Visual/ReflectionRay
@onready var normal_ray = $Visual/NormalRay

# Used to set the projectile to "inactive" while final animations, sounds, etc play out, before queue_free()
var hit = false : set = _on_hit

func _ready():	
	# Only allow the server to control projectiles
	if not multiplayer.is_server():
		set_physics_process(false)
		projectile_collision_shape.disabled = true
		hitbox_collision_shape.disabled = true
	else:
		time_to_live_timer.timeout.connect(_on_time_to_live_timer_timeout)
		time_to_live_timer.start()
		effect_wait_timer.timeout.connect(_on_effect_wait_timer_timeout)

func _physics_process(delta):
	if hit:
		return # Already hit, so we must be waiting for a timer to queue_free the object

	# Move the projectile, and return the colliding object if collision occurs
	# Here we ignore the y component of the direction, so that the bullets always fly horizontally
	velocity = -Vector3(transform.basis.z.x, 0.0, transform.basis.z.z) * projectile_velocity * delta
	var collision = move_and_collide(velocity)
	
	# This type of collision is with other CollisionShape3Ds, but does not include areas such as hurtboxes.
	# This means this collision is useful for detecting walls, etc, but not enemies.
	if collision:
		print(collision.get_collider().name)
		if collision.get_collider().is_in_group("Player"):
			pass
		else:
			collide_with_body(collision)
		
func collide_with_body(collision):
	var col_position = collision.get_position()
	var col_normal = collision.get_normal()
	
	# Projectile collided so turn of TTL timer, and create sparks instead
	time_to_live_timer.stop()
	effect_wait_timer.start()
	
	# Calculate the projectile's bounce (ricochet) vector from the collision normal
	var bounce_vec = velocity.bounce(col_normal)

	# Update ray indicators used for Debug view of projectile interations
	var dir_end = global_position + velocity.normalized() * DIRECTION_RAY_LENGTH
	direction_ray.set_target_position(direction_ray.to_local(dir_end))
	var bounce_end = global_position + bounce_vec.normalized() * BOUNCE_RAY_LENGTH
	reflection_ray.set_target_position(reflection_ray.to_local(bounce_end))
	var normal_end = global_position + col_normal.normalized() * NORMAL_RAY_LENGTH
	normal_ray.set_target_position(normal_ray.to_local(normal_end))

	create_sparks.rpc(col_position, bounce_end)
	
	hit = true
	destroy()
		
@rpc("call_local")
func create_sparks(col_position:Vector3, bounce_end:Vector3):
	# Create the sparks
	var sparks_scene = preload("res://Scenes/Weapons/Effects/sparks_3d.tscn")
	var sparks = sparks_scene.instantiate()
	get_tree().current_scene.get_node("InstantiatedScenes/Effects").add_child(sparks, true)
	sparks.global_position = col_position
	sparks.look_at(bounce_end)
	sparks.get_node("GPUParticles3D").emitting = true
	
func _on_time_to_live_timer_timeout():
	hit = true
	destroy()
	
func _on_effect_wait_timer_timeout():
	destroy()
	
func destroy():
	if not multiplayer.is_server():
		return
	# Remove the object after 'x' seconds
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
# Hitboxes are only configured on layers that interact with enemy hurtboxes, so the area should be an Enemy Hurtbox.
func _on_hitbox_area_entered(area):
	if not multiplayer.is_server():
		return

	print("(projectile.gd) Projectile hitbox entered area " + area.name)
	if area.get_parent().has_method("hit"):
		# Call hit with the damage that the projecile deals, and include the projectile's rotation
		# so that it can be used to set correct transform on particle effects on the incident body (blood spatter, etc). 
		area.get_parent().hit(damage, velocity)

	hit = true
	hit_enemy_sound.play()
	destroy()
	
func _on_hit(value):
	hit = value
	projectile_collision_shape.set_deferred("disabled", true)
	hitbox_collision_shape.set_deferred("disabled", true)
	_hide.rpc()

@rpc("call_local", "reliable")
func _hide():
	hide()

