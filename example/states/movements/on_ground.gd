tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(delta):
	if target.dir != 0:
		target.velocity.x = lerp(target.velocity.x,
				target.ground_speed * target.dir,
				target.acceleration * delta)
	else:
		target.velocity.x = lerp(target.velocity.x, 0, target.ground_friction * delta)
		if abs(target.velocity.x) < target.walk_margin: target.velocity.x = 0

	if Input.is_action_just_pressed("jump"):
		var _s = change_state("Jump")
	elif !target.is_on_floor():
		get_node("../InAir/Fall").add_timer("CoyoteTime", target.coyote_time)
		var _s = change_state("Fall")
	elif abs(target.velocity.x) < target.walk_margin && Input.is_action_just_pressed("crouch"):
		var _s = change_state("Crouch")
