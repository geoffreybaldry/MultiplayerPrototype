extends Sprite3D

@onready var health_bar_2d = $SubViewport/HealthBar2D

func _ready():
	health_bar_2d.no_health.connect(_on_no_health)
	health_bar_2d.show_healthbar.connect(_on_show_healthbar)

	texture = $SubViewport.get_texture()
	
	hide()

func init_health(_health):
	health_bar_2d.init_health(_health)
	
func _set_health(_new_health):
	health_bar_2d.health = _new_health

func _on_no_health():
	pass
	#queue_free()
	
func _on_show_healthbar(show_healthbar:bool):
	if show_healthbar:
		show()
	else:
		hide()
