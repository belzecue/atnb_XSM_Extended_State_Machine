extends KinematicBody2D
# All the logic is handled by the xsm below
# The Player script is only declaring variables
# Those variables can be acccessed in your States with target.variable


var velocity = Vector2()
var dir = 0

export (int) var gravity = 2500
export (int) var acceleration = 6

export (int) var ground_speed = 550
export (int) var ground_friction = 6
export (int) var walk_margin = 20
export (int) var run_margin = 400

export (int) var jump_speed = 250
export (int) var air_speed = 410
export (int) var air_friction = 8

export (float) var coyote_time = .1
export (float) var prejump_time = .3
export (float) var jump_time = 2.3
