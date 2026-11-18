extends Node

# Game Timer Variables
var elapsed = 0.0
var running = true
@onready var timer_label = $HUD/TimerLabel

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
