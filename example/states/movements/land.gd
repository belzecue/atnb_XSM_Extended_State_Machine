tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Land")


func _on_land_finished():
	# Here one must specify the parent also ("Parent/Child"),
	# because two states have the same name in the tree
	# Careful, the parents names should be unique, though
	var _s = change_state("OnGround/Idle")
