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
class_name State, "res://addons/xsm/state.png"
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
#
#  change_state("MyState")
#   "MyState" is the name of an existing Node State
#  change_state_node(my_state) or change_state_to()
#   my_state is an existing State Node
#  is_active("MyState") -> bool
#   returns true if a state "MyState" is active in this xsm
#  get_active_states() -> Dictionary:
#   returns a dictionary with all the active States
#  get_state("MyState) -> State
#   returns the State Node "MyState". You have to specify "Parent/MyState" if
#   "MyState" is not a unique name
#  get_active_substate()
#   returns the active substate (all the children if has_regions)
#
#  play("Anim")
#   plays the animation "Anim" of the State's AnimationPlayer
#  stop()
#   stops the current animation
#  is_playing("Anim)
#   returns true if "Anim" is playing
#
#  add_timer("Name", time)
#   adds a timer named "Name" and returns this timer
#   when the time is out, the function _on_timeout(_name) is called
#  del_timer("Name")
#   deletes the timer "Name"
#  is_timer("Name")
#   returns true if there is a Timer "Name" running in this State


signal state_entered(sender)
signal state_exited(sender)
signal state_updated(sender)
signal state_changed(sender, new_state)
signal substate_entered(sender)
signal substate_exited(sender)
signal substate_changed(sender)
signal disabled()
signal enabled()
signal some_state_changed(sender_node, new_state_node)
signal pending_state_changed(added_state_node)
signal pending_state_added(new_state_name)
signal active_state_list_changed(active_states_list)

# EXPORTS
#
# Is exported in "_get_property_list():"
var disabled := false setget set_disabled
# Is exported in "_get_property_list():"
var debug_mode := false
# Is exported in "_get_property_list():"
enum {ANIM_ENTER_NONE, ANIM_ENTER_STATE, ANIM_ENTER_CHOSE}
var anim_on_enter := 0 setget set_anim_on_enter
var anim_name := ""
enum {ANIM_FINISHED_NOTHING, ANIM_FINISHED_PARENT, ANIM_FINISHED_SELF}
var on_anim_finished := 0
# Is exported in "_get_property_list():"
var next_state: NodePath
# Has been moved to create a StateRegions Node
# export var has_regions := false

# Is exported in "_get_property_list():" for root only
var fsm_owner: NodePath
# Is exported in "_get_property_list():" for root only
var animation_player: NodePath

# VARS
#
enum {INACTIVE, ENTERING, ACTIVE, EXITING}
var status := INACTIVE
var state_root: State = null
var target: Node = null
# You can change the above line by the following one to be able to use
# autocompletion on target in any State (could be any type instead of
# KinematicBody2D of course, such as your Player ;) )!
# var target: KinematicBody2D = null
# var anim_player: AnimationPlayer = null
var last_state: State = null
var done_for_this_frame := false
var state_in_update := false

# Root variables
var pending_states := [] setget , get_pending_states
# This one is for the root state only. Allows XSM to avoid name redundancy
# Empty for any other state
var state_map := {} setget , get_state_map
# Those were only for the root
# Now each state has all its active children history stored
var duplicate_names := {} setget , get_duplicate_names # Stores number of times a state_name is duplicated
var active_states := {} setget , get_active_states
var active_states_history := [] setget , get_active_states_history
# Is exported in "_get_property_list():" for root only
# Default value is set in property_get_revert
var history_size: int

# For debug beautyprint
var changing_state_level := 0

#
# INIT
#
func _ready() -> void:
	# Deal with the next_state of the previous state
	# If you want to avoid setting an empty next_state, set it to itself in the inspector
	var node_pos = get_position_in_parent()
	if node_pos > 0:
		var prev_node = get_parent().get_child(node_pos-1)
		if prev_node.get_class() == "State" and prev_node.next_state.is_empty():
			prev_node.next_state = "../%s" % name

	if Engine.is_editor_hint():
		return

	set_anim_on_enter(anim_on_enter)

	if not fsm_owner.is_empty():
		target = get_node_or_null(fsm_owner)

	# all the root init logic here 
	if is_root():
		if fsm_owner.is_empty() and get_parent() != null:
			target = get_parent()
		state_map[name] = self
		init_children_state_map(state_map, self)
		enter()
		init_children_states(self, true)
		_after_enter(null)


func _exit_tree() -> void:
	var node_pos = get_position_in_parent()
	if node_pos > 0:
		var prev_node = get_parent().get_child(node_pos-1)
		if prev_node.get_class() == "State" and prev_node.next_state == "../%s" % name:
			prev_node.next_state = next_state


func _get_configuration_warning() -> String:
	for c in get_children():
		if c.get_class() != "State":
			return "Error : this Node has a non State child (%s)" % c.get_name()
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

	if is_root():
		# Adds a root category in the inspector
		properties.append({
			name = "StateRoot",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
		# Same as "export(int) var my_property"
		properties.append({
			name = "history_size",
			type = TYPE_INT,

		})
		properties.append({
			name = "fsm_owner",
			type = TYPE_NODE_PATH
		})
		properties.append({
			name = "animation_player",
			type = TYPE_NODE_PATH
		})

	# Adds a State category in the inspector
	properties.append({
		name = "State",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	properties.append({
		name = "disabled",
		type = TYPE_BOOL
	})
	properties.append({
		name = "debug_mode",
		type = TYPE_BOOL
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
	properties.append({
		name = "next_state",
		type = TYPE_NODE_PATH
	})

	return properties


func property_can_revert(property):
	if property == "history_size":
		return true
	if property == "next_state":
		return true
	return false


func _default_next_state() -> NodePath:
	if get_position_in_parent() >= get_parent().get_child_count() - 1:
		return NodePath()
	return NodePath("../%s" % get_parent().get_child(get_position_in_parent() + 1).name)

func property_get_revert(property):
	if property == "history_size":
		return 5
	if property == "next_state":
		return _default_next_state()


func set_disabled(new_disabled: bool) -> void:
	disabled = new_disabled
	if disabled:
		emit_signal("disabled")
	else:
		emit_signal("enabled")
	# set_disabled_children(new_disabled)


# func set_disabled_children(new_disabled: bool):
# 	for c in get_children():
# 		c.set_disabled(new_disabled)


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
# SETTERS AND GETTERS
# Those make sure that any access to those variables return the root one
# Does not work in an inherited class ???
# This is solved in Godot 4 !!! (hurray)
#
func get_pending_states():
	if is_root():
		return pending_states
	return state_root.pending_states


func get_state_map():
	if is_root():
		return state_map
	return state_root.state_map


func get_duplicate_names():
	if is_root():
		return duplicate_names
	return state_root.duplicate_names


func get_active_states():
	if is_root():
		return active_states
	return state_root.active_states


func get_active_states_history():
	if is_root():
		return active_states_history
	return state_root.active_states_history


#
# PROCESS - Use update() to add state logic
#
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not disabled and status == ACTIVE:
		if is_root():
			# First of all, reset the anti loop system
			reset_done_this_frame(false)
			# Then update every active state
			update_active_states(_delta)
			# Finally, update root's active states history dictionnary
			add_to_active_states_history(active_states.duplicate())


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
func change_state_to(new_state_node: State = null, args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:
	return change_state_node(new_state_node, args_on_enter, args_after_enter,
			args_before_exit, args_on_exit)


func change_state_node(new_state_node: State = null, args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:

	if new_state_node == null:
		new_state_node = self
	if new_state_node.is_disabled():
		return null
	if new_state_node.status != INACTIVE:
		return null

	if not state_root.state_in_update:
		# debug info
		if is_debugged():
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
	if is_debugged():
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
	if is_debugged():
		state_root.changing_state_level -= 1
		var debug_lvl = ""
		for i in state_root.changing_state_level:
			debug_lvl += " ⎸"
		print(debug_lvl, " \\_ %s changed state : '%s' -> '%s'" % [target.name, get_name(), new_state_node.get_name()])

	return new_state_node


func change_state(new_state: String = "", args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null) -> State:

	# finds the node of new_state, return self if empty
	var new_state_node: State = find_state_node_or_self(new_state)

	return change_state_node(new_state_node, args_on_enter, args_after_enter, args_before_exit, args_on_exit)


func change_to_next( args_on_enter = null, args_after_enter = null,
		args_before_exit = null, args_on_exit = null):
	change_state_node(get_node_or_null(next_state), args_on_enter, args_after_enter, args_before_exit, args_on_exit)


func change_to_next_substate():
	var substate = get_active_substate()
	if substate:
		substate.change_to_next()


func change_state_if(new_state: String, if_state: String) -> State:
	var s = find_state_node_or_self(if_state)
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
	var s: State = find_state_node_or_self(state_name)
	if s == null:
		return false
	return s.status == ACTIVE


# returns the first active substate or or null
func get_active_substate():
	for c in get_children():
		if c.status == ACTIVE:
			return c
	return null


func get_state(state_name: String) -> State:
	return find_state_node_or_self(state_name)


# index 0 is the most recent history
func get_previous_active_states(history_id: int = 0) -> Dictionary:
	if active_states_history.empty():
		return Dictionary()
	if active_states_history.size() <= history_id:
		return active_states_history[0]
	return active_states_history[history_id]


# CAREFUL IF YOU HAVE TWO STATES WITH THE SAME NAME, THE "state_name"
# SHOULD BE OF THE FORM "ParentName/ChildName"
func was_state_active(state_name: String, history_id: int = 0) -> bool:
	return get_previous_active_states(history_id).has(state_name)


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
			if c.target == null or c.target.is_empty():
				c.target = root_state.target
			if c.animation_player == null or c.animation_player.is_empty():
				# c.anim_player = root_state.anim_player
				c.animation_player = root_state.get_node(root_state.animation_player).get_path()
			if first_branch and c == get_child(0):
				c.status = ACTIVE
				c.enter()
				c.last_state = root_state
				c.init_children_states(root_state, true)
				c._after_enter(null)
			else:
				c.init_children_states(root_state, false)


# update the root active states history each frame
func add_to_active_states_history(new_active_states: Dictionary) -> void:
	state_root.active_states_history.push_front(new_active_states)
	while state_root.active_states_history.size() > history_size:
		var _last: Dictionary = active_states_history.pop_back()


# Remove a state from active states list
func remove_active_state(state_to_erase: State) -> void:
	var state_name: String = state_to_erase.name
	var name_in_state_map: String = state_name
	if not state_root.state_map.has(state_name):
		var parent_name: String = state_to_erase.get_parent().name
		name_in_state_map = str("%s/%s" % [parent_name, state_name])
	state_root.active_states.erase(name_in_state_map)
	# var ancester = self
	# while ancester.get_class() == "State":
	# 	ancester.active_states.erase(name_in_state_map)
	# 	ancester = ancester.get_parent()
	emit_signal("active_state_list_changed", state_root.active_states)


# Add to active states list
func add_active_state(state_to_add: State) -> void:
	var state_name: String = state_to_add.name
	var name_in_state_map: String = state_name
	if not state_root.state_map.has(state_name):
		var parent_name: String = state_to_add.get_parent().name
		name_in_state_map = str("%s/%s" % [parent_name, state_name])
	state_root.active_states[name_in_state_map] = state_to_add
	# var ancester = self
	# while ancester.get_class() == "State":
	# 	ancester.active_states[name_in_state_map] = state_to_add
	# 	ancester = ancester.get_parent()
	emit_signal("active_state_list_changed", state_root.active_states)


func find_state_node_or_self(new_state: String) -> State:
	if new_state == get_name() or new_state == "":
		return self

	var map: Dictionary = state_root.state_map
	if map.has(new_state):
		return map[new_state]

	if state_root.duplicate_names.has(new_state):
		if map.has( str("%s/%s" % [name, new_state]) ):
			return map[ str("%s/%s" % [name, new_state]) ]
		elif map.has( str("%s/%s" % [get_parent().name, new_state]) ):
			return map[ str("%s/%s" % [get_parent().name, new_state]) ]

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
	if is_disabled():
		return
	state_in_update = true
	if self == state_root:
		# activate the pending states for the root
		while pending_states.size() > 0:
			var new_state_with_args = pending_states.pop_front()
			var new_state_node: State = new_state_with_args[0]
			var arg1 = new_state_with_args[1]
			var arg2 = new_state_with_args[2]
			var arg3 = new_state_with_args[3]
			var arg4 = new_state_with_args[4]
			var new_state: State = change_state_node(new_state_node, arg1, arg2, arg3, arg4)
			emit_signal("pending_state_changed", new_state)
	update(_delta)
	for c in get_children():
		if c.get_class() == "State" and c.status == ACTIVE and !c.done_for_this_frame:
			c.update_active_states(_delta)
	_after_update(_delta)
	state_in_update = false


# In case of exit, exit the whole branch
func change_children_status_to_exiting() -> void:
	for c in get_children():
		if c.get_class() == "State" and c.status != INACTIVE:
			c.status = EXITING
			c.change_children_status_to_exiting()


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


func exit_children(args_before_exit = null, args_on_exit = null) -> void:
	for c in get_children():
		if c.get_class() == "State" and c.status == EXITING:
			c._before_exit(args_before_exit)
			c.exit_children()
			c.exit(args_on_exit)


func change_children_status_to_entering(new_state_path: NodePath) -> void:
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
	status = ACTIVE
	add_active_state(self)
	if anim_name != "":
		play(anim_name)
	_on_enter(args)
	emit_signal("state_entered", self)
	if not is_root():
		get_parent().emit_signal("substate_entered", self)


func enter_children(args_on_enter = null, args_after_enter = null) -> void:
	# if newstate's path tall enough, enter child that fits newstate's current lvl
	# else newstate's path smaller than here, enter first child
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


# States added here will be changed on next xsm update
# Careful, this is only for the root !!!
func new_pending_state(new_state_node: State, args_on_enter = null,
		args_after_enter = null, args_before_exit = null,
		args_on_exit = null) -> void:
	var new_state_array := []
	new_state_array.append(new_state_node)
	new_state_array.append(args_on_enter)
	new_state_array.append(args_after_enter)
	new_state_array.append(args_before_exit)
	new_state_array.append(args_on_exit)
	# pending to state_root
	state_root.pending_states.append(new_state_array)
	emit_signal("pending_state_added", new_state_node)


func _on_timer_timeout(timer_name: String) -> void:
	del_timer(timer_name)
	_on_timeout(timer_name)


func _on_animation_finished(finished_animation, wtf):
	match on_anim_finished:
		ANIM_FINISHED_PARENT:
			if get_parent().get_class() == "State":
				print("parnt here !!!")
				get_parent().change_to_next_substate()
		ANIM_FINISHED_SELF:
			change_to_next()


func reset_done_this_frame(new_done: bool) -> void:
	done_for_this_frame = new_done
	for c in get_children():
		if c.get_class() == "State":
			c.reset_done_this_frame(new_done)


func get_class() -> String:
	return "State"


func is_root() -> bool:
	return get_parent().get_class() != "State"


func is_disabled() -> bool:
	var ancester = self
	while ancester.get_class() == "State":
		if ancester.disabled:
			return true
		ancester = ancester.get_parent()
	return false


func is_debugged():
	var ancester = self
	while ancester.get_class() == "State":
		if ancester.debug_mode:
			return true
		ancester = ancester.get_parent()
	return false
