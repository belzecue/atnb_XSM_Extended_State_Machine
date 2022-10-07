tool
extends StateAnimation


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	target.get_node("Skin").modulate = Color.white


# Test of get_active_substate(), see in parent's script "RegionColor"
func who_was_i():
	print("I was Purple")
