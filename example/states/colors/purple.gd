tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	target.modulate = Color("8414d9")


func _on_update(_delta):
	if Input.is_action_just_pressed("prev_color"):
		var _s = change_state("Orange")
	elif Input.is_action_just_pressed("next_color"):
		var _s = change_state("Green")
