tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Walk")


func _on_update(_delta):
	if abs(target.velocity.x) < target.walk_margin:
		# Here one must specify the parent also ("Parent/Child"),
		# because two states have the same name in the tree
		# Careful, the parents names should be unique, though
		var _s = change_state("OnGround/Idle")
	elif abs(target.velocity.x) > target.run_margin:
		if !is_playing("Run"): play("Run")
	elif target.dir == 0:
		if !is_playing("Brake"): play("Brake")
	else:
		if !is_playing("Walk"): play("Walk")
