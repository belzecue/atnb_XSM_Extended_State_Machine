tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Idle")


func _on_update(_delta):
	if abs(target.velocity.x) > target.walk_margin:
		var _s = change_state("Walk")
