tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Crouch")


func _on_update(_delta):
	if Input.is_action_just_released("crouch"):
		# Here one must specify the parent also ("Parent/Child"),
		# because two states have the same name in the tree
		# Careful, the parents names should be unique, though
		var _s = change_state("OnGround/Idle")
