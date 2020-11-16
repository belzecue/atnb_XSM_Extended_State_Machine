tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	play("Crouch")


func on_update(_delta):
	if Input.is_action_just_released("crouch"):
		change_state("Idle")
