tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	target.modulate = Color("8414d9")


func after_enter():
	pass


func on_update(_delta):
	if Input.is_action_just_pressed("prev_color"):
		change_state("Orange")
	elif Input.is_action_just_pressed("next_color"):
		change_state("Green")


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass
