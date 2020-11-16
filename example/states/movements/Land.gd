tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Land")


func on_landed():
	change_state("Idle")
