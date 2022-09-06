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
class_name State
extends Node

# To use this plugin, you should inherit this class to add scripts to your nodes
# This kind of an implementation https://statecharts.github.io
# The two main differences with a classic fsm are:
#   The composition of states and substates
#   The regions (sibling states that stay active at the same time)
#
# Your script can implement those abstract functions:
#  func _on_enter() -> void:
#  func _after_enter() -> void:
#  func _on_update(_delta) -> void:
#  func _after_update(_delta) -> void:
#  func _before_exit() -> void:
#  func _on_exit() -> void:
#  func _on_timeout(_name) -> void:
#
# Call a method to your State in the intended track of AnimationPlayer
# if you want to act (ie change State) after or during an animation
#
# In those scripts, you can call the public functions:
#  change_state("MyState")
#   "MyState" is the name of an existing Node State
#  change_state_node(my_state)
#   my_state is an existing State Node
#  next_state()
#   Helper function to change to the next non disabled sibling state in tree
#  prev_state()
#   Helper function to change to the previous non disabled sibling state in tree
#  is_active("MyState") -> bool
#   returns true if a state "MyState" is active in this xsm
#  get_active_states() -> Dictionary:
#   returns a dictionary with all the active States
#  get_state("MyState) -> State
#   returns the State Node "MyState". You have to specify "Parent/MyState" if
#   "MyState" is not a unique name
#  play("Anim")
#   plays the animation "Anim" of the State's AnimationPlayer
#  stop()
#   stops the current animation
#  is_playing("Anim)
#   returns true if "Anim" is playing
#  add_timer("Name", time)
#   adds a timer named "Name" and returns this timer
#   when the time is out, the function _on_timeout(_name) is called
#  del_timer("Name")
#   deletes the timer "Name"
#  is_timer("Name")
#   returns true if there is a Timer "Name" running in this State
#  get_active_substate()
#   returns the active substate (all the children if has_regions)


signal state_entered(sender)
signal state_exited(sender)
signal state_updated(sender)
signal state_changed(sender, new_state)
signal substate_entered(sender)
signal substate_exited(sender)
signal substate_changed(sender)
signal disabled()
signal enabled()

export var disabled := false setget set_disabled
export var has_regions := false
export var debug_mode := false
export(NodePath) var fsm_owner = null
export(NodePath) var animation_player = null
export var anim_on_enter := ""

#var active := false
enum {INACTIVE, ENTERING, ACTIVE, EXITING}
var status := INACTIVE
var state_root: State = null
var target: Node = null
# You can change the above line by the following one to be able to use
# autocompletion on target in any State (could be any type instead of
# KinematicBody2D of course, such as your Player ;) )!
#var target: KinematicBody2D = null
var anim_player: AnimationPlayer = null
var last_state: State = null
var done_for_this_frame := false
var state_in_update := false


#
# INIT
#
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if fsm_owner != null:
		target = get_node(fsm_owner)
	if animation_player != null:
		anim_player = get_node(animation_player)



func _get_configuration_warning() -> String:
	for c in get_children():
		if c.get_class() != "State":
			return "Error : this Node has a non State child (%s)" % c.get_name()
	return ""


func set_disabled(new_disabled: bool) -> void:
	disabled = new_disabled
	if disabled:
		emit_signal("disabled")
	else:
		emit_signal("enabled")
	set_disabled_children(new_disabled)


func set_disabled_children(new_disabled: bool):
	for c in get_children():
		c.set_disabled(new_disabled)


# Careful, if your substates have the same name,
# their parents names must be different
# It would be easier if the state_root name is unique
func init_children_state_map(dict: Dictionary, new_state_root: State):
	state_root = new_state_root
	for c in get_children():
		if dict.has(c.name):
			var curr_state: State = dict[c.name]
			var curr_parent: State = curr_state.get_parent()
			dict.erase(c.name)
			dict[ str("%s/%s" % [curr_parent.name, c.name]) ] = curr_state
			dict[ str("%s/%s" % [name, c.name]) ] = c
			state_root.duplicate_names[c.name] = 1
		elif state_root.duplicate_names.has(c.name):
			dict[ str("%s/%s" % [name, c.name]) ] = c
			state_root.duplicate_names[c.name] += 1
		else:
			dict[c.name] = c
		c.init_children_state_map(dict, state_root)


#
# FUNCTIONS TO INHERIT
#
func _on_enter(_args) -> void:
	pass


func _after_enter(_args) -> void:
	pass


func _on_update(_delta: float) -> void:
	pass


func _after_update(_delta: float) -> void:
	pass


func _before_exit(_args) -> void:
	pass


func _on_exit(_args) -> void:
	pass


func _on_timeout(_name: String) -> void:
	pass


#
# FUNCTIONS TO CALL IN INHERITED STATES
#
func change_state_node(new_state_node: State = null, args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:

	if new_state_node == null:
		new_state_node = self
	if new_state_node.disabled:
		return null
	if new_state_node.status != INACTIVE:
		return null

	if not state_root.state_in_update:
		# debug info
		if state_root.debug_mode or debug_mode:
			print("[!!!] %s pending state : '%s' -> '%s'" 
					% [target.name, get_name(), new_state_node.get_name()])
		# can't process, add to pending states
		state_root.new_pending_state(new_state_node, args_on_enter, args_after_enter,
				args_before_exit, args_on_exit)
		return null

	# Should avoid infinite loops of state changes
	if done_for_this_frame:
		return null	

	# debug
	if state_root.debug_mode or debug_mode:
		var debug_lvl = ""
		for i in state_root.changing_state_level:
			debug_lvl += " ⎸"
		print(debug_lvl, " /‾ %s changing state : '%s' -> '%s'" % [target.name, get_name(), new_state_node.get_name()])
		state_root.changing_state_level += 1

	# get the closest active parent
	var active_root: State = get_active_root(new_state_node)

	# change the children status to EXITING
	active_root.change_children_status_to_exiting()
	# exits all active children of the old branch,
	# from farthest to active_root (excluded)
	# If EXITED, change the status to INACTIVE
	active_root.exit_children(args_before_exit, args_on_exit)

	# change the children status to ENTERING
	active_root.change_children_status_to_entering(new_state_node.get_path())
	# enters the nodes of the new branch from the parent to the next_state
	# enters the first leaf of each following branch
	# If ENTERED, change the status to ACTIVE
	active_root.enter_children(args_on_enter, args_after_enter)

	# sets this State as last_state for the new one
	new_state_node.last_state = self

	# set "done this frame" to avoid another round of state change in this branch
	active_root.reset_done_this_frame(true)

	# signal the change
	emit_signal("state_changed", self, new_state_node)
	if not is_root() :
		new_state_node.get_parent().emit_signal("substate_changed", new_state_node)
	state_root.emit_signal("some_state_changed", self, new_state_node)

	# debug
	if state_root.debug_mode or debug_mode:
		state_root.changing_state_level -= 1
		var debug_lvl = ""
		for i in state_root.changing_state_level:
			debug_lvl += " ⎸"
		print(debug_lvl, " \\_ %s changed state : '%s' -> '%s'" % [target.name, get_name(), new_state_node.get_name()])
		if debug_lvl == "":
			print("")

	return new_state_node


func change_state(new_state: String, args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:

	# finds the node of new_state, return self if empty
	var new_state_node: State = find_state_node(new_state)

	return change_state_node(new_state_node, args_on_enter, args_after_enter, args_before_exit, args_on_exit)


# Two helper functions to change to the next non disabled sibling state
# only if parent does not have_regions
# it ends at the last sibling on this branch
func next_state(args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:
	
	var parent = get_parent()
	if parent.has_regions:
		return null

	var got_myself = false
	for i in parent.get_child_count():
		var sibling = parent.get_child(i)
		if got_myself:
			if not sibling.disabled:
				return change_state_node(sibling, args_on_enter,
					args_after_enter, args_before_exit, args_on_exit)
		elif parent.get_child(i) == self:
			got_myself = true
	return null


func prev_state(args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:
	
	var parent = get_parent()
	if parent.has_regions:
		return null

	var got_myself = false
	var i_max = parent.get_child_count() - 1
	for i in parent.get_child_count():
		var sibling = parent.get_child(i_max - i)
		if got_myself:
			if not sibling.disabled:
				return change_state_node(sibling, args_on_enter,
					args_after_enter, args_before_exit, args_on_exit)
		elif parent.get_child(i_max - i) == self:
			got_myself = true
	return null



# Old function name, if you used it, I... am sorry
# func goto_state(new_state: String) -> void:
# 	change_state(new_state)


func change_state_if(new_state: String, if_state: String) -> State:
	var s = find_state_node(if_state)
	if s == null or s.status == ACTIVE:
		return change_state(new_state)
	return null


func has_parent(state_node: State) -> bool:
	var parent = get_parent()
	if parent == state_node:
		return true
	if parent.get_class() != "State" or parent == state_root:
		return false
	return parent.has_parent(state_node)


func is_active(state_name: String) -> bool:
	var s: State = find_state_node(state_name)
	if s == null:
		return false
	return s.status == ACTIVE


# returns the first active substate or all children if has_regions
func get_active_substate():
	if has_regions and status == ACTIVE:
		return get_children()
	else:
		for c in get_children():
			if c.status == ACTIVE:
				return c
	return null


func get_state(state_name: String) -> State:
	return find_state_node(state_name)


func get_active_states() -> Dictionary:
	return state_root.active_states


func play(anim: String, custom_speed: float = 1.0, from_end: bool = false) -> void:
	if status == ACTIVE and anim_player != null and anim_player.has_animation(anim):
		if anim_player.current_animation != anim:
			anim_player.stop()
			anim_player.play(anim)


func play_backwards(anim: String) -> void:
	play(anim, -1.0, true)


func play_blend(anim: String, custom_blend: float, custom_speed: float = 1.0,
		from_end: bool = false) -> void:
	if status == ACTIVE and anim_player != null and anim_player.has_animation(anim):
		if anim_player.current_animation != anim:
			anim_player.play(anim, custom_blend, custom_speed, from_end)


func play_sync(anim: String, custom_speed: float = 1.0,
		from_end: bool = false) -> void:
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
	if status == ACTIVE and anim_player != null and anim_player.has_animation(anim):
		anim_player.queue(anim)


func stop(reset: bool = true) -> void:
	if status == ACTIVE and anim_player != null:
		anim_player.stop(reset)
		state_root.current_anim_priority = 0


func is_playing(anim: String) -> bool:
	if anim_player != null:
		return anim_player.current_animation == anim
	return false


func add_timer(name: String, time: float) -> Timer:
	del_timer(name)
	var timer := Timer.new()
	add_child(timer)
	timer.set_name(name)
	timer.set_one_shot(true)
	timer.start(time)
	timer.connect("timeout",self,"_on_timer_timeout",[name])
	return timer


func del_timer(name: String) -> void:
	if has_node(name):
		get_node(name).stop()
		get_node(name).queue_free()
		get_node(name).set_name("to_delete")


func del_timers() -> void:
	for c in get_children():
		if c is Timer:
			c.stop()
			c.queue_free()
			c.set_name("to_delete")


func has_timer(name: String) -> bool:
	return has_node(name)

#
# PRIVATE FUNCTIONS
#
func init_children_states(root_state: State, first_branch: bool) -> void:
	for c in get_children():
		if c.get_class() == "State":
			c.status = INACTIVE
			c.state_root = root_state
			if c.target == null:
				c.target = root_state.target
			if c.anim_player == null:
				c.anim_player = root_state.anim_player
			if first_branch and ( has_regions or c == get_child(0) ):
				c.status = ACTIVE
				c.enter()
				c.last_state = root_state
				c.init_children_states(root_state, true)
				c._after_enter(null)
			else:
				c.init_children_states(root_state, false)


func find_state_node(new_state: String) -> State:
	if new_state == get_name() or new_state == "":
		return self

	var state_map: Dictionary = state_root.state_map
	if state_map.has(new_state):
		return state_map[new_state]

	if state_root.duplicate_names.has(new_state):
		if state_map.has( str("%s/%s" % [name, new_state]) ):
			return state_map[ str("%s/%s" % [name, new_state]) ]
		elif state_map.has( str("%s/%s" % [get_parent().name, new_state]) ):
			return state_map[ str("%s/%s" % [get_parent().name, new_state]) ]

	return null


func get_active_root(new_state_node: State) -> State:
	var result: State = new_state_node
	while not result.status == ACTIVE and not result.is_root():
		result = result.get_parent()
	return result


func update(_delta: float) -> void:
	if status == ACTIVE:
		_on_update(_delta)
		emit_signal("state_updated", self)


func update_active_states(_delta: float) -> void:
	if disabled:
		return
	state_in_update = true
	update(_delta)
	for c in get_children():
		if c.get_class() == "State" and c.status == ACTIVE and !c.done_for_this_frame:
			c.update_active_states(_delta)
	_after_update(_delta)
	state_in_update = false


func change_children_status_to_exiting() -> void:
	if has_regions:
		for c in get_children():
			c.status = EXITING
			c.change_children_status_to_exiting()
	else:
		for c in get_children():
			if c.get_class() == "State" and c.status != INACTIVE:
				c.status = EXITING
				c.change_children_status_to_exiting()


func exit(args = null) -> void:
	del_timers()
	_on_exit(args)
	status = INACTIVE
	emit_signal("state_exited", self)
	if not is_root():
		get_parent().emit_signal("substate_exited", self)


func exit_children(args_before_exit = null, args_on_exit = null) -> void:
	for c in get_children():
		if c.get_class() == "State" and c.status == EXITING:
			c._before_exit(args_before_exit)
			c.exit_children()
			c.exit(args_on_exit)


func change_children_status_to_entering(new_state_path: NodePath) -> void:
	if has_regions:
		for c in get_children():
			c.status = ENTERING
			c.change_children_status_to_entering(new_state_path)
			return

	var new_state_lvl: int = new_state_path.get_name_count()
	var current_lvl: int = get_path().get_name_count()
	if new_state_lvl > current_lvl:
		for c in get_children():
			var current_name: String = new_state_path.get_name(current_lvl)
			if c.get_class() == "State" and c.get_name() == current_name:
				c.status = ENTERING
				c.change_children_status_to_entering(new_state_path)
	else:
		if get_child_count() > 0:
			var c: Node = get_child(0)
			if get_child(0).get_class() == "State":
				c.status = ENTERING
				c.change_children_status_to_entering(new_state_path)


func enter(args = null) -> void:
	if disabled:
		return
	status = ACTIVE
	if anim_on_enter != "":
		play(anim_on_enter)
	_on_enter(args)
	emit_signal("state_entered", self)
	if not is_root():
		get_parent().emit_signal("substate_entered", self)


func enter_children(args_on_enter = null, args_after_enter = null) -> void:
	if disabled:
		return
	# if hasregions, enter all children and that's all
	# if newstate's path tall enough, enter child that fits newstate's current lvl
	# else newstate's path smaller than here, enter first child
	if has_regions:
		for c in get_children():
			c.enter(args_on_enter)
			c.enter_children(args_on_enter, args_after_enter)
			c._after_enter(args_after_enter)
		return

	for c in get_children():
		if c.get_class() == "State" and c.status == ENTERING:
			c.enter(args_on_enter)
			c.enter_children(args_on_enter, args_after_enter)
			c._after_enter(args_after_enter)


func reset_children_status():
	for c in get_children():
		if c.get_class() == "State":
			c.status = INACTIVE
			c.reset_children_status()


func _on_timer_timeout(name: String) -> void:
	del_timer(name)
	_on_timeout(name)


func reset_done_this_frame(new_done: bool) -> void:
	done_for_this_frame = new_done
	if not is_atomic():
		for c in get_children():
			if c.get_class() == "State":
				c.reset_done_this_frame(new_done)


func get_class() -> String:
	return "State"


func is_atomic() -> bool:
	return get_child_count() == 0


func is_root() -> bool:
	return false
