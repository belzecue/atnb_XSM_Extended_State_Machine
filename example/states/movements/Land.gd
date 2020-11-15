tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Land")


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


func on_landed():
	change_state("Idle")
