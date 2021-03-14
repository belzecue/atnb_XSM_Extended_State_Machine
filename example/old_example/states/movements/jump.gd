tool
extends State


var jumping = false


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	play("Jump")
	var _t = add_timer("JumpTimer", target.jump_time)
	jumping = true


func _on_update(_delta):
	if Input.is_action_just_released("jump"):
		jumping = false

	if jumping:
		target.velocity.y = -target.jump_speed


func _on_exit(_args):
	jumping = false


func _on_jump_finished():
	play("FlyUp")


func _on_timeout(_name):
	jumping = false
	var _s = change_state("Fall")
