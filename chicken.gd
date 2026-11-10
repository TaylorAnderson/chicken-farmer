extends Node2D

enum State {
	WANDERING,
	IDLE,
	EATING,
	PANICKED,
	SHOCKED,
}

var state:State;

@export var min_idle_time:float = 0;
@export var max_idle_time:float = 5;

@export var min_eat_time:float = 1;
@export var max_eat_time:float = 2

@export var min_wander_time:float = 1;
@export var max_wander_time:float = 3;

@export var min_run_time:float = 2;
@export var max_run_time:float = 4;

@export var wander_speed:float = 100;
@export var run_speed:float = 0;
@export var avoidance_speed:float = 100;


var velocity:Vector2 = Vector2.ZERO;
var accel:Vector2 = Vector2.ZERO;

@onready var sprite = $AnimatedSprite2D

var timer:float = 0;

@onready var perception:Perception = $Perception

var current_speed:float = 0;
var predator_spotted:Predator = null;
func _ready():
	change_state(State.IDLE if randf() > 0.5 else State.WANDERING)
	
func _physics_process(delta):
	timer -= delta;
	
	if velocity.length() > 0:
		perception.rotation = velocity.angle();
		perception.force_update();

	match state:
		State.IDLE:
			if timer < 0:
				change_state(State.WANDERING if randf() > 0.5 else State.EATING)
		
		State.EATING:
			if timer < 0:
				change_state(State.IDLE)
		State.WANDERING:
			var predator = perception.look_for(Predator)
			if predator:
				predator_spotted = predator;
				change_state(State.SHOCKED)
			elif timer < 0:
				change_state(State.IDLE)
			else:
				accel += get_avoidance_vector();
				accel += avoid_threats_vector();
		

		
		State.SHOCKED:
			if not sprite.is_playing():
				change_state(State.PANICKED)

		State.PANICKED:
			var predator = perception.look_for(Predator)
			if timer < 0 and not predator:
				change_state(State.IDLE)
			else:
				accel += get_avoidance_vector();
				accel += avoid_threats_vector();
			

	velocity = velocity.limit_length(current_speed)
	position += velocity * delta;
	velocity += accel * delta;
	accel = Vector2.ZERO;
	

func get_avoidance_vector():
	# farthest away we can get from the vel is the opposite
	var closest_ray:Vector2 = velocity * -1;
	var open_dirs = perception.get_open_directions()
	for dir:Vector2 in open_dirs:
		if abs(dir.angle_to(velocity)) < abs(closest_ray.angle_to(velocity)):
			closest_ray = dir;
	if open_dirs.size() > 0:
		closest_ray = open_dirs.pick_random()
	var steering = closest_ray * avoidance_speed
	steering -= velocity;
	return steering;
	
func avoid_threats_vector():
	var steering = Vector2.ZERO
	
	var predator = perception.look_for(Predator)
	if predator != null:
		steering = (global_position - predator.global_position)
	
	var player = perception.look_for(Player)
	if player != null:
		steering = (global_position - player.global_position)
	
	if steering != Vector2.ZERO:
		steering = steering.normalized() * avoidance_speed
		steering -= velocity;
	return steering
	
func change_state(new_state:State):
	state = new_state;
	match new_state:
		State.IDLE:
			sprite.play("idle")
			velocity = Vector2.ZERO;
			timer = randf_range(min_idle_time, max_idle_time)
		State.EATING:
			sprite.play("eat")
			timer = randf_range(min_eat_time, max_eat_time)
		State.WANDERING:
			sprite.play("run")
			timer = randf_range(min_wander_time, max_wander_time)
			var dir = randf_range(0, PI * 2)
			velocity = Vector2.from_angle(dir).normalized() * wander_speed
			current_speed = wander_speed;
		State.PANICKED:
			timer = randf_range(min_run_time, max_run_time)
			sprite.play("run")
			velocity = (global_position - predator_spotted.global_position).normalized() * run_speed
			current_speed = run_speed;
		State.SHOCKED:
			velocity = Vector2.ZERO;
			sprite.play("shock")
