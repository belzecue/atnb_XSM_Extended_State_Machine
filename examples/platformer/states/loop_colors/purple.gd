tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	target.modulate = Color.purple


# Test of get_active_substate(), see in parent's script "RegionColor"
func who_was_i():
	print("I was Purple")
