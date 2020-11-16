tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	target.modulate = Color("ee8e28")


func on_update(_delta):
	if Input.is_action_just_pressed("prev_color"):
		change_state("Green")
	elif Input.is_action_just_pressed("next_color"):
		change_state("Purple")
