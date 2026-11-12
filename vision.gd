@tool
class_name Vision
extends Node2D

@export var fov:float = 90;
@export var radius:float = 45;
@export var steps:int = 6;
@export_tool_button("Generate Rays") var gen_rays_action = generate_rays
@export_flags_2d_physics var ray_mask:int;

var rays:Array[RayCast2D] = [];

func _ready():
	for child in get_children():
		if child is RayCast2D: rays.append(child)

func generate_rays():
	for child in get_children():
		if child is RayCast2D: child.queue_free();
	var angle = -fov/2
	var step_size = floori(fov / steps)
	for i in steps:
		var ray = RayCast2D.new()
		ray.target_position = Vector2.from_angle(deg_to_rad(angle)).normalized() * radius
		add_child(ray);
		ray.owner = get_tree().edited_scene_root
		ray.collide_with_areas = true;
		ray.add_exception(get_parent())
		ray.collision_mask = ray_mask;
		angle += step_size;
		
func get_open_directions() -> Array[Vector2]:
	var open_rays:Array[Vector2] = [];
	for ray in rays:
		if not ray.is_colliding():
			open_rays.append(ray.target_position.rotated(rotation))
	return open_rays
	
func look_for(type:Script):
	for ray in rays:
		if ray.is_colliding():
			if is_instance_of(ray.get_collider(), type):
				return ray.get_collider()
	return null;
		
func force_update():
	for ray in rays:
		ray.force_raycast_update();
