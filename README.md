XSM Extended State Machine
==========================

A freely inspired implementation of [StateCharts](https://statecharts.github.io/what-is-a-statechart.html) for Godot. This plugin provides States composition, regions and helper functions for animations and timers. It is licensed GNU GPL and written by [ATN](https://gitlab.com/atnb).

Understanding XSM
-----------------

A Finite State Machine (FSM) is a way for developpers to separate their code's logic into different parts. In Godot, it would be in different Nodes. XSM allows to have substates of a State so that you don't have to create a complex inheritage pattern. You can simply add State Nodes as children of a State Node. If you do so, when a child is active, all his parents are active too.

If a State has_regions, all its children are active or inactive at the same time, as soon as it is active or inactive.

It allows schemas such as :
![Image](https://statecharts.github.io/on-off-delayed-exit-1.svg "statechart")
![Image](https://statecharts.github.io/glossary/parallel.svg "statechart")
more on : [StateCharts](https://statecharts.github.io/what-is-a-statechart.html)

How to use XSM
-----------------

You can add a State node to your scene. This State wiil be the root of your XSM. Then you can add different States to this root and separate the logic of your scene into those different sub-States.

An empty State template is provided in res://script_template/empty_state.gd. You just need to add a script to your State and specify this one as a model.

By default, your XSM is not activated, you should activate it (check your root node's inspector) to have it work.

Each State can have its own target (any Node of the scene, including another State) and animation player specified in the inspector. If you don't, XSM wiil get the root's ones. If the root does not have a target, it will use its parent as target. If the root does not have an AnimationPlayer, it will just give you a warning.

When you enter a State, XSM will first exit the old branch. Starting from the common root of the new State and the old one, it will call _before_exit(), exit the children, then call _on_exit() for each State.
Then it will enter the new branch. Starting from the common root of the new State and the old one, it will call _on_enter(), enter the children, then call _after_enter() for each State. If the specified State is not the last of the branch, XSM is going to enter each following first chid.

In each State's script, you can implement the following functions:
```python
#  func _on_enter() -> void:
#  func _after_enter() -> void:
#  func _on_update(_delta) -> void:
#  func _after_update(_delta) -> void:
#  func _before_exit() -> void:
#  func _on_exit() -> void:
#  func _on_timeout(_name) -> void:
```

