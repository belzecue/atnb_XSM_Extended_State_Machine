tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter():
	play("Crouch")


func _on_update(_delta):
	if Input.is_action_just_released("crouch"):
		change_state("Idle")
