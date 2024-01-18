extends CharacterBody3D

@export var projectile_velocity : float
@export var player_id : int
@export var damage : int

@onready var collision_shape = $CollisionShape3D
@onready var time_to_live = $Timers/TimeToLive
@onready var effect_wait_timer = $Timers/EffectWaitTimer


# Used to set the projectile to "inactive" while final animations, sounds, etc play out, before queue_free()
var hit = false

func _ready():	
	# Only allow the server to control projectiles
	if not multiplayer.is_server():
		set_physics_process(false)
		collision_shape.disabled = true
	else:
		time_to_live.timeout.connect(_on_time_to_live_timeout)
		time_to_live.start()
		effect_wait_timer.timeout.connect(_on_effect_wait_timer_timeout)

func _physics_process(delta):
	if hit:
		return

	# Move the projectile, and return the colliding object if collision occurs
	# Here we ignore the y component of the direction, so that the bullets always fly horizontally
	var collision = move_and_collide(-Vector3(transform.basis.z.x, 0.0, transform.basis.z.z) * projectile_velocity * delta)
	
	# This type of collision is with other CollisionShape3Ds, but does not include areas such as hurtboxes.
	# This means this collision is useful for detecting walls, etc, but not enemies.
	if collision:
		var col_position = collision.get_position()
		var col_normal = collision.get_normal()
		print("Collided with normal of " + str(col_normal))
		var col_angle = collision.get_angle()
		print("Collided with angle of " + str(rad_to_deg(col_angle)))
		# Projectile collided so turn of TTL timer, and create sparks instead
		time_to_live.stop()
		effect_wait_timer.start()
		create_sparks.rpc(col_position, col_normal, col_angle)
		
		#var collider = collision.get_collider()
		#if collider and collider.has_method("hit"):
			# Call the hit method, which for this type of collision might cause sparks, etc.
			# We include the collison object so that we can get the position and normal, etc.
		#	collider.hit.rpc(collision)
		collision_shape.set_deferred("disabled", true)
		hit = true
		#explode.rpc()
		
@rpc("call_local")
func create_sparks(col_position:Vector3, col_normal:Vector3, col_angle:float):
	#pass
	var sparks_scene = preload("res://Scenes/Weapons/Effects/projectile_impact_sparks.tscn")
	var sparks = sparks_scene.instantiate()
	#sparks.global_position = col_position
	sparks.rotation.y = col_angle
	add_child(sparks, true)
	print("Sparks Emitting")
	sparks.emitting = true
	

func _on_time_to_live_timeout():
	collision_shape.set_deferred("disabled", true)
	hit = true
	explode.rpc()
	
func _on_effect_wait_timer_timeout():
	explode.rpc()
	
@rpc("call_local")
func explode():
	destroy()
	
func destroy():
	if not multiplayer.is_server():
		return
	queue_free()
	

# Hitboxes are only configured on layers that interact with enemy hurtboxes, so the area should be an Enemy Hurtbox.
func _on_hitbox_area_entered(area):
	if not multiplayer.is_server():
		return
		
	print("(projectile.gd) Projectile hitbox entered area " + area.name)
	if area.get_parent().has_method("hit"):
		# Call hit with the damage that the projecile deals, and include the projectile's tranform
		# so that it can be used to set correct transform on particle effects on the incident body. 
		area.get_parent().hit.rpc(damage, global_rotation)
	
	collision_shape.set_deferred("disabled", true)
	hit = true
	explode.rpc()
	

# This should not get used because the hitbox is only on a layer with Enemy Hurtboxes, which are Area3Ds. Just for testing.
#func _on_hitbox_body_entered(body):
#	if not multiplayer.is_server():
#		return
#
#	print("(projectile.gd)Projectile hitbox entered body " + body.name)
#	if body.has_method("hit"):
#		body.hit.rpc()
#
#	collision_shape.set_deferred("disabled", true)
#	hit = true
#	explode.rpc()
