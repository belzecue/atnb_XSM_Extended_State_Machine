tool
extends State


# FUNCTIONS TO INHERIT #

# COMMENTED BECAUSE A DEFAULT ANIMATION IS SET IN THE INSPECTOR
# func _on_enter(_args):
# 	play("Idle")


func _on_update(_delta):
	if abs(target.velocity.x) > target.walk_margin:
		var _s = change_state("Walk")


func _on_land_finished():
	var _s = change_state_node()
