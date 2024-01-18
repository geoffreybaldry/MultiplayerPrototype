extends Node3D

@onready var muzzle_positon = $Model/Muzzle_Positon
@onready var cooldown_timer = $CooldownTimer
@onready var audio_stream_player = $SoundEffects/AudioStreamPlayer


@export var projectile_scene : PackedScene
@export var projectile_velocity : float
@export var damage:int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fire(player_id):
	if cooldown_timer.time_left != 0:
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.player_id = player_id
	projectile.global_transform = muzzle_positon.global_transform
	projectile.damage = damage
	get_tree().current_scene.get_node("Projectiles").add_child(projectile, true)

	# Set the projectile's speed to that of the weapon's projectile_speed
	# This way different weapons can give a different speed to similar projectiles
	projectile.projectile_velocity = projectile_velocity
	
	# Play the firing sound
	audio_stream_player.play()
	
	cooldown_timer.start() 
