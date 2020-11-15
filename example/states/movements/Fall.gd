tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Fall")


func after_enter():
	pass


func on_update(_delta):
	print(target.is_on_floor())
	if target.is_on_floor() && get_node_or_null("PreJump") != null:
		change_state("Jump")
		return
	elif target.is_on_floor():
		change_state("Land")
		return

	if Input.is_action_just_pressed("jump") && get_node_or_null("CoyoteTime") != null:
		change_state("Jump")
	elif Input.is_action_just_pressed("jump"):
		add_timer("PreJump",target.prejump_time)


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass
