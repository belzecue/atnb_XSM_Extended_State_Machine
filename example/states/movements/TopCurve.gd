tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("TopCurve")


func after_enter():
	pass


func on_update(_delta):
	pass


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass


# This method is called by my AnimationPlayer, at the end of the "TopCurve" Animation
func on_finished_animation():
		change_state("Fall")
