tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(delta):
	target.dir = 0

	if Input.is_action_pressed("left"):
		target.dir = -1
		if !target.get_node("Sprite").flip_h: target.get_node("Sprite").flip_h = true
	elif Input.is_action_pressed("right"):
		target.dir = 1
		if target.get_node("Sprite").flip_h: target.get_node("Sprite").flip_h = false

	target.velocity.y += delta * target.gravity


func _after_update(_delta):
	target.velocity = target.move_and_slide(target.velocity, Vector2.UP)
