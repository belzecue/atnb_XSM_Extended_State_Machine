tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	var _st = change_state("NoJump")


func _on_update(_delta) -> void:
	get_active_substate().jump()
	if not is_playing("Jump") and not Input.is_action_pressed("jump"):
		var _st = change_state("Fall")
	if anim_player.current_animation_position >= 0.1:
		var skin = target.get_node("Skin")
		skin.rotation = - target.velocity.angle_to(Vector2.UP)
		skin.position = Vector2()


func _on_exit(_args) -> void:
	del_timers()
	var skin = target.get_node("Skin")
	skin.position = Vector2()
	

func _on_jump_finished() -> void:
	play("Fall")


func _on_timeout(_name) -> void:
	var _st = change_state("Fall")
