tool
extends State


# FUNCTIONS TO INHERIT #

func _on_update(delta):
	target.dir = 0

	if Input.is_action_pressed("left"):
		target.dir = -1
	elif Input.is_action_pressed("right"):
		target.dir = 1

	target.velocity.y += delta * target.gravity


func _after_update(_delta):
	target.velocity = target.move_and_slide(target.velocity, Vector2.UP)

	if target.velocity.x > 0:
		target.get_node("Skin").flip_h = false
	elif target.velocity.x < 0:
		target.get_node("Skin").flip_h = true
