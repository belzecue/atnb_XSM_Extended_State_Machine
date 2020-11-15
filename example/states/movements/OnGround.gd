tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	pass


func after_enter():
	pass


func on_update(delta):
	if target.dir != 0:
		target.velocity.x = lerp(target.velocity.x, target.ground_speed * target.dir, target.acceleration * delta)
	else:
		target.velocity.x = lerp(target.velocity.x, 0, target.ground_friction * delta)
		if abs(target.velocity.x) < target.walk_margin: target.velocity.x = 0

	if Input.is_action_pressed("jump"):
		change_state("Jump")

	elif !target.is_on_floor():
		get_parent().get_node("InAir/Fall").add_timer("CoyoteTime", target.coyote_time)
		change_state("Fall")


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(name):
	pass
