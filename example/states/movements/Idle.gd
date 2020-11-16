tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Idle")


func on_update(_delta):
	if abs(target.velocity.x) > target.walk_margin:
		change_state("Walk")
