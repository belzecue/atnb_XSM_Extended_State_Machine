tool
extends State


# FUNCTIONS TO INHERIT #
func on_enter():
	pass


func after_enter():
	pass


func on_update(delta):
	target.dir = 0

	if Input.is_action_pressed("left"):
		target.dir = -1
	elif Input.is_action_pressed("right"):
		target.dir = 1

	target.velocity.y += delta * target.gravity


func after_update(_delta):
	target.move_and_slide(target.velocity, Vector2.UP)


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(name):
	pass
