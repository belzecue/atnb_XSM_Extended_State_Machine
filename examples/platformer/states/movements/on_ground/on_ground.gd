tool
extends State


export (int) var ground_speed = 450
export (int) var acceleration = 6
export (int) var walk_margin = 20
export (int) var run_margin = 350


# FUNCTIONS TO INHERIT #
func _on_enter(_args) -> void:
	var _st1 = change_state("CanDash")
	var _st2 = change_state("CanJump")
	

func _on_update(delta):
	if target.dir == 0:
		# Check if player in on the edge to stop the movement
		var result = target.ray( sign(target.velocity.x), target.BOTTOM, 1.5)
		if result.empty():
			var _st = change_state("OnEdge")
		elif abs(target.velocity.x) < walk_margin:
			if not is_active("Crouch") and not is_active("Land"):
				var _st = change_state("Idle")
		else:
			var _st = change_state("Brake")

	else:
		if abs(target.velocity.x) >= run_margin:
			var _st = change_state("Run")
		else:
			var _s = change_state("Walk")
	
		target.velocity.x = lerp(target.velocity.x,
				ground_speed * target.dir,
				acceleration * delta)

	if not target.is_on_floor():
		var _s1 = change_state("CoyoteTime", "OnGround")
		var _s2 = change_state("Fall")
