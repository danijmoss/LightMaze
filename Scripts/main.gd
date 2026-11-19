extends Node

# Game Timer Variables
var elapsed = 0.0
var running = true
@onready var timer_label = $HUD/TimerLabel
@onready var result_label = $HUD/ResultPanel/ResultLabel
@onready var result_panel = $HUD/ResultPanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if running:
		elapsed += delta
		timer_label.text = "%.2f" % elapsed


func _on_goal_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		running = false
		result_panel.visible = true
		result_label.text = "Finished! \n %.2f" % elapsed
		$HUD/ResultPanel/ButtonRow/YesButton.grab_focus()


func _on_yes_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_no_button_pressed() -> void:
	get_tree().quit()
