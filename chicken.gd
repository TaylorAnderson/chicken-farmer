extends RigidBody2D
@onready var run_timer = $RunTime
@onready var wait_timer = $WaitTime

@export var min_wait_time:float = 0;
@export var max_wait_time:float = 5;

@export var min_run_time:float = 1;
@export var max_run_time:float = 3;

@export var min_run_speed:float = 1;
@export var max_run_speed:float = 3;

var wander_velocity:Vector2 = Vector2.ONE;

var velocity:Vector2 = Vector2.ZERO;
@onready var sprite = $AnimatedSprite2D

func _ready():
	wait_timer.start(randf_range(min_wait_time, max_wait_time))
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	run_timer.timeout.connect(_on_run_timer_timeout)
func _on_wait_timer_timeout():
	sprite.play("run")
	var direction_angle = randf_range(0, 360)
	velocity = Vector2.from_angle(deg_to_rad(direction_angle)) * randf_range(min_run_speed, max_run_speed)
	run_timer.start(randf_range(min_run_time, max_run_time));
func _on_run_timer_timeout():
	sprite.play("idle")
	velocity = Vector2.ZERO;
	constant_force = Vector2.ZERO;
	wait_timer.start(randf_range(min_wait_time, max_wait_time))
	
func _physics_process(_delta):
	add_constant_force(velocity)
