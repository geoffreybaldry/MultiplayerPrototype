extends ProgressBar

signal no_health
signal show_healthbar

@onready var damage_bar = $DamageBar
@onready var timer = $Timer

var health = 0 : set = _set_health

func _ready():
	pass

func init_health(_health):
	print("(health_bar_2d.gd) Init with health " + str(_health) + " on peer " + str(multiplayer.get_unique_id()))
	max_value = _health
	health = _health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _set_health(new_health):
	print("(health_bar_2d.gd) _set_health with new_health " + str(new_health) + " on peer " + str(multiplayer.get_unique_id()))
	var prev_health = health
	health = min(max_value, new_health)
	value = health

	# Can be caught by parent to queue_free() the bar, for example
	if health <= 0:
		emit_signal("no_health")
	
	if health < max_value:
		emit_signal("show_healthbar", true)
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func _on_timer_timeout():
	animate_healthbar()

#@rpc("call_local")
func animate_healthbar():
	print("Animate healthbar called on peer " + str(multiplayer.get_unique_id()))
	var tween = get_tree().create_tween()
	tween.tween_property(damage_bar, "value", health, 0.5).set_trans(Tween.TRANS_LINEAR)
