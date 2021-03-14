extends KinematicBody2D
# All the logic is handled by the xsm below
# The Player script is only declaring variables
# Those variables can be acccessed in your States with target.variable


var velocity = Vector2()
var dir = 0

export (int) var gravity = 2500
export (int) var acceleration = 15

export (int) var ground_speed = 680
export (int) var ground_friction = 6
export (int) var walk_margin = 80
export (int) var run_margin = 150

export (int) var jump_speed = 450
export (int) var air_speed = 610
export (int) var air_friction = 8

export (float) var coyote_time = 0.1
export (float) var prejump_time = 0.3
export (float) var jump_time = 0.3
