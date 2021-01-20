tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Land")


func _on_land_finished():
	var _s = change_state("Idle")
