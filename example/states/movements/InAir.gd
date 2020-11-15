tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	pass


func after_enter():
	pass


func on_update(delta):
	if target.dir != 0:
		target.velocity.x = lerp(target.velocity.x, target.air_speed * target.dir, target.acceleration * delta)
	if target.dir == 0:
		target.velocity.x = lerp(target.velocity.x,  0, target.air_friction * delta)
		if abs(target.velocity.x) < target.walk_margin: target.velocity.x = 0

	if get_node("Jump").jumping: target.velocity.y = -target.jump_speed

	if get_node("Jump").jumping && Input.is_action_just_released("jump"):
		get_node("Jump").jumping = false


func after_update(_delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(_name):
	pass
