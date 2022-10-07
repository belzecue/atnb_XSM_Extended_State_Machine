tool
extends StateAnimation


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	target.get_node("Skin").modulate = Color.green


func who_was_i():
	print("I was Green")
