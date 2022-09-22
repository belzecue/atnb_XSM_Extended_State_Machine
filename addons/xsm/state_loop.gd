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
class_name StateLoop
extends State

# StateLoop allows for easy navigation in its substates
# Just call next or prev to advance in the loop

signal looped()


var moving_forward := true

export(NodePath) var exit_state
# Based on the loop_mode enum of AudioStreamSample for coherence
enum LoopMode {LOOP_DISABLED, LOOP_FORWARD, LOOP_BACKWARD, LOOP_PING_PONG}
export(LoopMode) var loop_mode := LoopMode.LOOP_FORWARD setget set_loop_mode

#
# INIT
#
func set_loop_mode(value):
	loop_mode = value
	if loop_mode == LoopMode.LOOP_BACKWARD:
		moving_forward = false


#
# PUBLIC FUNCTIONS
#
func next(args_on_enter = null, args_after_enter = null, args_before_exit = null, args_on_exit = null):

	if get_child_count() == 0:
		return

	var current_index = get_active_substate().get_index()
	var next_index = current_index + 1

	match loop_mode:
		LoopMode.LOOP_DISABLED:
			return

		LoopMode.LOOP_FORWARD:
			if next_index == get_child_count():
				next_index = 0

		LoopMode.LOOP_BACKWARD:
			next_index = current_index -1
			if next_index < 0:
				next_index = get_child_count() - 1

		LoopMode.LOOP_PING_PONG:
			if moving_forward:
				if next_index == get_child_count():
					next_index = current_index -1
					moving_forward = false
			else:
				next_index = current_index - 1
				if next_index < 0:
					next_index = 1
					moving_forward = true

	change_state_node(get_child(next_index), args_on_enter, args_after_enter, args_before_exit, args_on_exit)


func prev(args_on_enter = null, args_after_enter = null, args_before_exit = null, args_on_exit = null):
	var current_index = get_active_substate().get_index()
	var next_index = current_index + 1

	match loop_mode:
		LoopMode.LOOP_DISABLED:
			return

		LoopMode.LOOP_FORWARD:
			next_index = current_index -1
			if next_index < 0:
				next_index = get_child_count() - 1

		LoopMode.LOOP_BACKWARD:
			if next_index == get_child_count():
				next_index = 0

		LoopMode.LOOP_PING_PONG:
			if moving_forward:
				next_index = current_index - 1
				if next_index < 0:
					next_index = 1
					moving_forward = false
			else:
				if next_index == get_child_count():
					next_index = current_index -1
					moving_forward = true

	change_state_node(get_child(next_index), args_on_enter, args_after_enter, args_before_exit, args_on_exit)


func exit_loop(args_on_enter = null, args_after_enter = null, args_before_exit = null, args_on_exit = null):
	if exit_state == "":
		return
	var exit_node = get_node(exit_state)
	change_state_node(exit_node, args_on_enter, args_after_enter, args_before_exit, args_on_exit)

#
# PRIVATE FUNCTIONS
#
