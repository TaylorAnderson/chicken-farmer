extends Camera2D
@export var player:Player


func _process(delta):
	position = lerp(position, player.position + player.facing_dir * 0.1, 0.1)
	
