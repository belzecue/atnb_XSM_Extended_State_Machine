extends KinematicBody2D


var velocity = Vector2()
var dir = 0

export (int) var gravity = 2500
export (int) var acceleration = 15

export (int) var ground_speed = 680
export (int) var ground_friction = 6

export (int) var jump_speed = 850
export (int) var air_speed = 610
export (int) var air_friction = 8

export (int) var walk_margin = 80
export (int) var run_margin = 150

export (float) var coyote_time = 0.1
export (float) var prejump_time = 0.3
export (float) var jump_time = 0.3


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
