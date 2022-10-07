tool
extends StateAnimation


# FUNCTIONS TO INHERIT #

# COMMENTED: DEFAULT ANIMATION IS SET IN THE INSPECTOR in Walk State
# func _on_enter(_args):
# 	play("Walk")


# func _on_update(_delta):
# 	if abs(target.velocity.x) < target.walk_margin:
# 		var _s = change_state("Idle")
# 	elif abs(target.velocity.x) > target.run_margin:
# 		if !is_playing("Run") and !is_playing("Walk2Run"): 
# 			# The animation Walk2Run calls play_run() when done
# 			play("Walk2Run")
# 	elif target.dir == 0:
# 		if !is_playing("Brake"): 
# 			play("Brake")
# 	else:
# 		if !is_playing("Walk"): 
# 			play("Walk")


# Called at the end of the Walk2Run animation
func play_run():
	play("Run")
