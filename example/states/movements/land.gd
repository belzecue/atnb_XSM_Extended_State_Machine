tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter():
	play("Land")


func _on_land_finished():
	change_state("Idle")
