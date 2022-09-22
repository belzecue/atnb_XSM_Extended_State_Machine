tool
extends State


var jumping : bool = false


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	jumping = true
	var _st = change_state("NoJump")
	# var _err = anim_player.connect("animation_finished", self, "_on_animation_finished")


func _on_update(_delta) -> void:
	if jumping:
		get_active_substate().jump()
		if not Input.is_action_pressed("jump"):
			var _st = change_state("Fall")
	else :
		var _st = change_state("Fall")


func _on_exit(_args) -> void:
	# anim_player.disconnect("animation_finished", self, "_on_animation_finished")
	jumping = false
	del_timers()
	var skin = target.get_node("Skin")
	skin.position.y = 0
	skin.rotation = 0	


func _on_jump_finished() -> void:
	# anim_player.disconnect("animation_finished", self, "_on_animation_finished")
	play("Fall")
	var skin = target.get_node("Skin")
	skin.position.y = 0
	# skin.rotation = - target.velocity.angle_to(Vector2.UP) #+ PI + target.dir * PI/2


func _on_timeout(_name) -> void:
	jumping = false
