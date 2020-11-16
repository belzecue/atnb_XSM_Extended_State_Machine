tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter():
	play("Idle")


func _on_update(_delta):
	if abs(target.velocity.x) > target.walk_margin:
		change_state("Walk")
