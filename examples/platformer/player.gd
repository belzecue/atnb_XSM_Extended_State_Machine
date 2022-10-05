extends KinematicBody2D
# All the logic is handled by the xsm below
# The Player script is only declaring variables
# Those variables can be acccessed in your States with target.variable


var velocity = Vector2()
var dir = 0
var wall_dir = 0

# export (int) var gravity = 2500
# export (int) var acceleration = 6

# export (int) var ground_speed = 450
# export (int) var ground_friction = 6
# export (int) var walk_margin = 20
# export (int) var run_margin = 350

# export (int) var jump_top_margin = 50
# export (int) var air_speed = 300
# export (int) var air_friction = 8

# export (float) var coyote_time = .1
# export (float) var prejump_time = .4
# export (float) var jump_time = .3
# export (int) var jump_min_height = 16
# export (int) var jump_max_height = 48

# export (float) var predash_time = .4
# export (int) var dash_speed = 1000
# export (int) var dash_distance = 128

onready var skin = get_node("Skin")

enum {TOP_FRONT, MIDDLE_FRONT, BOTTOM_FRONT, BOTTOM}


func ray(ray_dir, goal, length_factor):
	var space_state = get_world_2d().direct_space_state
	var to = global_position
	
	match goal:
		TOP_FRONT:
			to.x += length_factor * ray_dir * $Body.shape.extents.x
			to.y -= length_factor * $Body.shape.extents.y
		MIDDLE_FRONT:
			to.x += length_factor * ray_dir * $Body.shape.extents.x
		BOTTOM_FRONT:
			to.x += length_factor * ray_dir * $Body.shape.extents.x
			to.y += length_factor * $Body.shape.extents.y
		BOTTOM:
			to.y += length_factor * $Body.shape.extents.y

	return space_state.intersect_ray(global_position, to, [self])


func detect_wall_dir():
	var raysult1 = ray(skin.scale.x, MIDDLE_FRONT, 1.5)
	var raysult2 = ray(skin.scale.x, BOTTOM_FRONT, 1.5)
	var raysult3 = ray(skin.scale.x, TOP_FRONT, 1.5)
	if raysult1.empty() and raysult2.empty() and raysult3.empty():
		wall_dir = - skin.scale.x
	else: 
		wall_dir = skin.scale.x
