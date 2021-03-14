tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter():
	target.modulate = Color("168318")


func _on_update(_delta):
	if Input.is_action_just_pressed("prev_color"):
		change_state("Purple")
	elif Input.is_action_just_pressed("next_color"):
		change_state("Orange")
