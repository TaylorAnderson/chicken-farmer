extends CharacterBody2D
class_name Player
@onready var sprite = $AnimatedSprite2D

@export var speed:float = 40;

var facing_dir:Vector2 = Vector2.ZERO
func _physics_process(delta):
	var input_velocity = Input.get_vector("left", "right", "up", "down") * speed;
	
	if input_velocity.length() > 0.0: 
		facing_dir = input_velocity
		var vertical_anim = ""
		if input_velocity.y < 0: vertical_anim = "up"
		if input_velocity.y > 0: vertical_anim = "down"
		
		var horizontal_anim = ""
		if input_velocity.x != 0: horizontal_anim = "side"
		if input_velocity.x > 0: sprite.flip_h = false;
		if input_velocity.x < 0: sprite.flip_h = true;
		
		
		sprite.play("%s%s%s" % [horizontal_anim, "_" if horizontal_anim.length() > 0 and vertical_anim.length() > 0 else "", vertical_anim])
	
	velocity = input_velocity
	move_and_slide()
