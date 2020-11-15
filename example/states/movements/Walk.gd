tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Walk")


func after_enter():
	pass


func on_update(_delta):
	if abs(target.velocity.x) > target.run_margin:
		change_state("Run")
	if abs(target.velocity.x) < target.walk_margin:
		change_state("Idle")


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass
