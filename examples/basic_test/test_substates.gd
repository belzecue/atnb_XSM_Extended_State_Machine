tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	target.get_parent().show()


func _after_enter(_args) -> void:
	pass


func _on_update(_delta) -> void:
	for c in target.get_children():
		c.queue_free()

	var l = Label.new()
	l.text = "%s history:" % name
	target.add_child(l)

	for hist in get_active_states_history():
		var l1 = Label.new()
		l1.text = str(hist.keys())
		target.add_child(l1)


func _on_exit(_args) -> void:
	target.get_parent().hide()
