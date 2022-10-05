tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	target.get_node("Skin").modulate = Color.orange


func who_was_i():
	print("I was Orange")
