extends Sprite2D

@export var blood_splatters: Array[Texture] #An Array with the textures

func _ready():
	texture = blood_splatters.pick_random()
	modulate = Color.DARK_RED
	flip_h =  bool(randi() % 2)
	flip_v = bool(randi() % 2)
	rotation_degrees = randf_range(0, 360)
	
