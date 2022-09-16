tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Walk")


func _on_update(_delta):
	if abs(target.velocity.x) < target.walk_margin:
		var _s = change_state("Idle")
	elif abs(target.velocity.x) > target.run_margin:
		if !is_playing("Run"): play("Run")
	elif target.dir == 0:
		if !is_playing("Brake"): play("Brake")
	else:
		if !is_playing("Walk"): play("Walk")
