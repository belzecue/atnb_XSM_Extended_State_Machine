tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("GreenToPurple")


func _on_update(_delta):
	if Input.is_action_just_pressed("prev_color"):
		var _s = change_state("Orange")
	elif Input.is_action_just_pressed("next_color"):
		var _s = change_state("Green")


# Test of get_active_substate(), see in parent's script "RegionColor"
func who_was_i():
	print("I was Purple")
