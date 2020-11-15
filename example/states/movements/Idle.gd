tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Idle")


func after_enter():
	pass


func on_update(_delta):
	if abs(target.velocity.x) > target.walk_margin:
		change_state("Walk")


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass
