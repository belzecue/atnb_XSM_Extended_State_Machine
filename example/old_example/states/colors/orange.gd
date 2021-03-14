tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("PurpleToOrange")
#	target.modulate = Color("#ee8e28")


func _on_update(_delta):
	if Input.is_action_just_pressed("prev_color"):
		var _s = change_state("Green")
	elif Input.is_action_just_pressed("next_color"):
		var _s = change_state("Purple")


func who_was_i():
	print("I was Orange")
