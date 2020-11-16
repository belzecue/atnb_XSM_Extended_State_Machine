tool
class_name State extends Node


signal state_entered(sender)
signal state_exited(sender)
signal state_updated(sender)
signal state_changed(sender)

export var active = false
export var has_regions = false
export var is_fallback = false
export(NodePath) var fsm_owner = null
export(Array,NodePath) var anim_players = []

var target = null
var last_state = null
var fallback = null
var done_for_this_frame = false


# INIT
func _ready():
	if is_root() && active:
		if fsm_owner != null:  target = get_node(fsm_owner)
		elif get_parent() != null: target = get_parent()
		else : target = self
		is_fallback = true
		last_state = self
		init_states(self, true)
		change_state("") # TODO remove


func init_states(root_state, first_branch):
	for c in get_children():
		if c.get_class() == "State":
			c.active = false
			if c.fsm_owner != null:
				c.target = c.get_node(c.fsm_owner)
			else: c.target = root_state.target
			c.fallback = root_state
			if first_branch && (has_regions || c == get_child(0)):
				c.active = true
				c.last_state = root_state
				c.init_states(root_state, true)
			else :
				c.init_states(root_state, false)


func _get_configuration_warning():
	if is_root() && !active:
		return "Warning : Your root State is not active. Activate to have it work"
	for c in get_children():
		if c.get_class() != "State":
			return "Error : this Node has a non State child (%s)" %c.get_name()
	if is_root() && anim_players.size() == 0:
		return "Warning : Your root State has no AnimationPlayer registered (check your inspector)"
	return ""


# PROCESS
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if is_root() && active:
		reset_done_this_frame(false)
		update_active_states(delta)


func update(delta):
	if active:
		on_update(delta)
		emit_signal("state_updated", self)


func update_active_states(delta):
	update(delta)
	for c in get_children():
		if c.get_class() == "State" && c.active && !c.done_for_this_frame:
			c.update_active_states(delta)
	after_update(delta)

# CHANGE STATE
func change_state(new_state):
	if done_for_this_frame: return
	# if empty, go to fallback or itself
	if new_state == "":
		if fallback != null: new_state = fallback.get_name()
		else : new_state = get_name()
	# finds the path to next state return if null or active
	var new_state_node = find_state_node(new_state, null)
	if new_state_node == null: return
	#var new_state_node = get_node(new_path)
	if new_state != get_name() && new_state_node.active: return
	# compare the current path and the new one -> get the common_root
	var common_root = get_common_root(new_state_node)
	# exits all active children of the old branch, from farthest to common_root (excluded)
	common_root.exit_children()
	# enters the nodes of the new branch from the parent to the next_state
	# enters the first leaf of each following branch
	common_root.enter_children(new_state_node.get_path())
	#sets this one as last_state for the new one
	if(is_fallback): new_state_node.fallback = self
	else: new_state_node.fallback = fallback
	new_state_node.last_state = self
	# set "done this frame" to avoid another round of state change in this branch
	common_root.reset_done_this_frame(true)
	# signal the change
	emit_signal("state_changed", self)
	print("'%s' -> '%s'" % [get_name(), new_state])


func find_state_node(new_state, just_done):
	if get_name() == new_state: return self
	var found = null
	for c in get_children():
		if c.get_class() == "State" && c != just_done:
			found = c.find_state_node(new_state,self)
			if found != null: return found
	var parent = get_parent()
	if parent != null && parent.get_class() == "State" && parent != just_done:
		found = parent.find_state_node(new_state, self)
		if found != null: return found
	return found


func get_common_root(new_state):
	var new_path = new_state.get_path()
	var curr_path = get_path()
	var common_root_path = ""
	var i = 0
	while i < new_path.get_name_count() && i < curr_path.get_name_count():
		if new_path.get_name(i) != curr_path.get_name(i):
			break
		common_root_path = str(common_root_path, "/", new_path.get_name(i))
		i += 1
	return get_node(common_root_path)


func exit():
	active = false
	on_exit()
	emit_signal("state_exited", self)


func exit_children():
	for c in get_children():
		if c.get_class() == "State" && c.active:
			c.before_exit()
			c.exit_children()
			c.exit()


func enter():
	active = true
	on_enter()
	emit_signal("state_entered", self)


# TODO Continue here to add the regions
func enter_children(new_state_path):
	# if hasregions, enter all children and that's all
	# if newstate's path tall enough, enter child that fits newstate's current level
	# else newstate's path smaller than here, enter first child
	if has_regions:
		for c in get_children():
			c.enter()
			c.enter_children(new_state_path)
			c.after_enter()
		return
	var new_state_lvl = new_state_path.get_name_count()
	var current_lvl = get_path().get_name_count()
	if new_state_lvl > current_lvl:
		for c in get_children():
			if c.get_class() == "State" && c.get_name() == new_state_path.get_name(current_lvl):
				c.enter()
				c.enter_children(new_state_path)
				c.after_enter()
	else:
		if get_child_count() > 0:
			var c = get_child(0)
			if get_child(0).get_class() == "State":
				c.enter()
				c.enter_children(new_state_path)
				c.after_enter()


# ANIMATIONS
func anim_player(new_name):
	if new_name == "" && anim_players.size() > 0:
		return get_node(anim_players[0])
	for ap in anim_players:
		if ap != null && ap.get_name(ap.get_name_count() - 1) == new_name:
			return get_node(ap)
	if !is_root():
		return get_parent().anim_player(new_name)
	return null


func play(anim, anim_player = ""):
	var ap = anim_player(anim_player)
	if ap != null && ap.has_animation(anim) :
		if ap.current_animation != anim: ap.play(anim)


func is_playing(anim, anim_player = ""):
	var ap = anim_player(anim_player)
	return ap.current_animation == anim


# TIMERS
func add_timer(name, time):
	del_timer(name)
	var timer = Timer.new()
	add_child(timer)
	timer.set_name(name)
	timer.set_one_shot(true)
	timer.start(time)
	timer.connect("timeout",self,"_on_timer_timeout",[name])


func del_timer(name):
	if has_node(name) :
		get_node(name).queue_free()
		get_node(name).set_name("to_delete")


func _on_timer_timeout(name):
	del_timer(name)
	on_timeout(name)


# UTILITY SMALL PRIVATE FUNCTIONS
func reset_done_this_frame(new_done):
	done_for_this_frame = new_done
	if not is_atomic():
		for c in get_children():
			if c.get_class() == "State":
				c.reset_done_this_frame(new_done)


func get_class():	return "State"


func is_atomic():
	return get_child_count() == 0


func is_root():
	return get_parent().get_class() != "State"


# FUNCTIONS TO INHERIT #
func on_enter():
	pass


func after_enter():
	pass


func on_update(delta):
	pass


func after_update(delta):
	pass


func before_exit():
	pass


func on_exit():
	pass


func on_timeout(name):
	pass
