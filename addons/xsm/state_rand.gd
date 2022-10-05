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
class_name StateRand, "res://addons/xsm/state_rand.png"
extends State

# StateRand Can chose a random state based on priorities
# Call rand_state() to chose a random substate


var randomized := true setget set_randomized
# This seed will not be used if this state is randomized
var state_seed := 0
var priorities = {} setget set_priorities


var is_ready := false

#
# INIT
#
func _ready():
	if randomized:
		randomize()
	else:
		seed(state_seed)

	var _c1 = connect("child_entered_tree", self, "substate_entered")
	var _c2 = connect("child_exiting_tree", self, "substate_exiting")
	for c in get_children():
		if c.get_class() == "State":
			var _conn = c.connect("renamed", self, "substate_renamed", [c.name, c])


func set_randomized(value):
	randomized = value
	property_list_changed_notify()
	

func set_priorities(value):
	if get_parent(): # is false during ready !!!
		for k in value.keys():
			var nod  = get_node_or_null(k)
			if not k is String or not nod or nod.get_class() != "State":
				value.erase(k)
			if value[k] and value[k] is int:
				priorities[k] = value[k]
	else:
		priorities = value


# We want to add some export variables in their categories
# And separate those of the root state
func _get_property_list():
	var properties = []

	# Adds a State category in the inspector
	properties.append({
		name = "StateRand",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	})
	properties.append({
		name = "randomized",
		type = TYPE_BOOL,
	})
	if not randomized:
		properties.append({
			name = "state_seed",
			type = TYPE_INT,
		})
	properties.append({
		name = "priorities",
		type = TYPE_DICTIONARY,
	})
	
	return properties


#
# PUBLIC FUNCTIONS
#
func change_to_next_substate():
	print("rand change")
	pass


#
# PRIVATE FUNCTIONS
#
func _process(delta):
	pass


func substate_entered(node):
	if node.get_class() == "State":
		priorities[node.name] = 1
		var _c = node.connect("renamed", self, "substate_renamed", [node.name, node])


func substate_exiting(node):
	if node.get_class() == "State":
		priorities.erase(node.name)


# in case a state child is renamed, update its name in priorities
# have to reconnect its signal
func substate_renamed(old_name, node):
	var old_priority = priorities[old_name]
	priorities.erase(old_name)
	priorities[node.name] = old_priority
	node.disconnect("renamed", self, "substate_renamed")
	var _c = node.connect("renamed", self, "substate_renamed", [node.name, node])
