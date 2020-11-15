tool
extends State


var jumping = false


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Jump")
	add_timer("JumpTimer", target.jump_time)
	jumping = true


func after_enter():
	pass


func on_update(_delta):
	if Input.is_action_just_released("jump"):
		jumping = false

	if jumping:
		target.velocity.y = -target.jump_speed
		if last_state.get_name() == "Fall":
			jumping = false


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	jumping = false


func on_jump_finished():
	play("FlyUp")


func on_timeout(_name):
	jumping = false
	change_state("FlyUp")
