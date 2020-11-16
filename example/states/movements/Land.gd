tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter():
	play("Land")


func _on_AnimationPlayer_animation_finished(_anim_name):
	change_state("Idle")
