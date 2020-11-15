tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("FlyUp")


func after_enter():
	pass


func on_update(_delta):
	if target.velocity.y > -250:
		change_state("TopCurve")


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass
