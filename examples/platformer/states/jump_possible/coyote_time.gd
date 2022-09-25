tool
extends State


var origin_state

# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(from) -> void:
	var _t = add_timer("CoyoteTime", target.coyote_time)
	origin_state = from


func _on_update(_delta) -> void:
	if Input.is_action_just_pressed("jump"):
		if origin_state == "OnGround":
			var _st = change_state("Jump")
		elif origin_state == "OnWall":
			var _st = change_state("WallJump", true)

			
func _on_exit(_args):
	del_timers()


func _on_timeout(_name) -> void:
	var _st = change_state("CanPreJump")
