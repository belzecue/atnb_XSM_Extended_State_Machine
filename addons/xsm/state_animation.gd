# MIT LICENSE Copyright 2020-2021 Etienne Blanc - ATN
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
tool
class_name StateAnimation, "res://addons/xsm/state.png"
extends State

# EXPORTS
#
# Is exported in "_get_property_list():"
enum {ANIM_ENTER_NONE, ANIM_ENTER_STATE, ANIM_ENTER_CHOSE}
var anim_on_enter := 0 setget set_anim_on_enter
var anim_name := ""
enum {ANIM_FINISHED_NOTHING, ANIM_FINISHED_PARENT, ANIM_FINISHED_SELF}
var on_anim_finished := 0

# Is exported in "_get_property_list():" for root only
var animation_player: NodePath

#
# INIT
#
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_anim_on_enter(anim_on_enter)


func _get_configuration_warning() -> String:
	return ""


func set_anim_on_enter(value):
	anim_on_enter = value
	if anim_on_enter == ANIM_ENTER_NONE:
		anim_name = ""
	elif anim_on_enter == ANIM_ENTER_STATE:
		anim_name = name
	property_list_changed_notify()


# We want to add some export variables in their categories
# And separate those of the root state
func _get_property_list():
	var properties = []


	# Adds a State category in the inspector
	properties.append({
		name = "StateAnimation",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})

	properties.append({
		name = "anim_on_enter",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM, 
		"hint_string": "None:0, State's name:1, Chose anim:2"
	})
	if anim_on_enter == ANIM_ENTER_CHOSE:
		properties.append({
			name = "anim_name",
			type = TYPE_STRING
		})
	if anim_on_enter != ANIM_ENTER_NONE:
		properties.append({
			name = "on_anim_finished",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM, 
			"hint_string": "Do Nothing:0, Parent's choice:1, Next from Self:2"
		})

	return properties



#
# SETTERS AND GETTERS
# Those make sure that any access to those variables return the root one
# Does not work in an inherited class ???
# This is solved in Godot 4 !!! (hurray)
#

#
# PROCESS - Use update() to add state logic
#


#
# FUNCTIONS TO INHERIT
#
func _on_finished(_name: String) -> void:
	pass


#
# FUNCTIONS TO CALL IN INHERITED STATES
#
func play(anim: String, custom_speed: float = 1.0, from_end: bool = false) -> void:
	if disabled or status != ACTIVE:
		return
	var anim_player = get_node_or_null(animation_player)
	if anim_player and anim_player.has_animation(anim):
		if anim_player.current_animation != anim:
			anim_player.stop()
			anim_player.play(anim)
			# The goal here is to provide a way to change state automatically at the end of an animation
			if anim_player.is_connected("animation_finished", self, "_on_animation_finished"):
				anim_player.disconnect("animation_finished", self, "_on_animation_finished")
			anim_player.connect("animation_finished", self, "_on_animation_finished", [anim])


func play_backwards(anim: String) -> void:
	play(anim, -1.0, true)


func play_blend(anim: String, custom_blend: float, custom_speed: float = 1.0,
		from_end: bool = false) -> void:
	var anim_player = get_node_or_null(animation_player)
	if status == ACTIVE and anim_player != null and anim_player.has_animation(anim):
		if anim_player.current_animation != anim:
			anim_player.play(anim, custom_blend, custom_speed, from_end)


func play_sync(anim: String, custom_speed: float = 1.0,
		from_end: bool = false) -> void:
	var anim_player = get_node_or_null(animation_player)
	if status == ACTIVE and anim_player != null and anim_player.has_animation(anim):
		var curr_anim: String = anim_player.current_animation
		if curr_anim != anim and curr_anim != "":
			var curr_anim_pos: float = anim_player.current_animation_position
			var curr_anim_length: float = anim_player.current_animation_length
			var ratio: float = curr_anim_pos / curr_anim_length
			play(anim, custom_speed, from_end)
			anim_player.seek(ratio * anim_player.current_animation_length)
		else:
			play(anim, custom_speed, from_end)


func pause() -> void:
	stop(false)


func queue(anim: String) -> void:
	var anim_player = get_node_or_null(animation_player)
	if status == ACTIVE and anim_player != null and anim_player.has_animation(anim):
		anim_player.queue(anim)


func stop(reset: bool = true) -> void:
	var anim_player = get_node_or_null(animation_player)
	if status == ACTIVE and anim_player != null:
		anim_player.stop(reset)
		state_root.current_anim_priority = 0


func is_playing(anim: String) -> bool:
	var anim_player = get_node_or_null(animation_player)
	if anim_player != null:
		return anim_player.current_animation == anim
	return false


#
# PRIVATE FUNCTIONS
#

func exit(args = null) -> void:
	del_timers()
	_on_exit(args)
	var anim_player = get_node(animation_player)
	if anim_player and anim_player.is_connected("animation_finished", self, "_on_animation_finished"):
		anim_player.disconnect("animation_finished", self, "_on_animation_finished")
	status = INACTIVE
	remove_active_state(self)
	emit_signal("state_exited", self)
	if not is_root():
		get_parent().emit_signal("substate_exited", self)


func enter(args = null) -> void:
	status = ACTIVE
	add_active_state(self)
	if anim_name != "":
		play(anim_name)
	_on_enter(args)
	emit_signal("state_entered", self)
	if not is_root():
		get_parent().emit_signal("substate_entered", self)


func _on_animation_finished(finished_animation, wtf):
	match on_anim_finished:
		ANIM_FINISHED_NOTHING:
			_on_finished(finished_animation)
		ANIM_FINISHED_PARENT:
			if get_parent().get_class() == "State":
				print("parnt here !!!")
				get_parent().change_to_next_substate()
		ANIM_FINISHED_SELF:
			change_to_next()
				

