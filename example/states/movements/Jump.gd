tool
extends State


var jumping = false


# FUNCTIONS TO INHERIT #
func _on_enter():
	play("Jump")
	add_timer("JumpTimer", target.jump_time)
	jumping = true


func _on_update(_delta):
	if Input.is_action_just_released("jump"):
		jumping = false

	if jumping:
		target.velocity.y = -target.jump_speed
		if last_state.get_name() == "Fall":
			jumping = false


func _on_exit():
	jumping = false


func _on_jump_finished():
	play("FlyUp")


func _on_timeout(_name):
	jumping = false
	change_state("Fall")
