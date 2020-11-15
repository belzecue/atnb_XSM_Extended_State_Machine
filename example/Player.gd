extends KinematicBody2D


var velocity = Vector2()
var dir = 0

export (int) var gravity = 2500
export (int) var acceleration = 10

export (int) var ground_speed = 320
export (int) var ground_friction = 8

export (int) var jump_speed = 650
export (int) var air_speed = 320
export (int) var air_friction = 1.5

export (int) var walk_margin = 80
export (int) var run_margin = 150

export (float) var coyote_time = 0.1
export (float) var prejump_time = 0.3
export (float) var jump_time = 0.3
