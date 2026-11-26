extends Node

# Path to Save File
const SAVE_PATH := "user://maze_save.cfg"

# Freeze timer during the light
var revealing := false

# Best Time Label Variables
static var best_time := -1.0
@onready var best_label = $HUD/BestLabel

# Game Timer Variables
var elapsed = 0.0
var running = true
@onready var timer_label = $HUD/TimerLabel
@onready var result_label = $HUD/ResultPanel/ResultLabel
@onready var result_panel = $HUD/ResultPanel

# Glow Gauge
@onready var glow_gauge = $HUD/GlowGauge

# Sun / Light Reference
@onready var sun = $DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.sparkles_collected.connect(_on_sparkles_collected) # count the sparkles collected
	load_best_time()	# load the best time
	update_best_label()		# update the best time label
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if running:
		elapsed += delta
		timer_label.text = "%.2f" % elapsed


func _on_goal_body_entered(body: Node3D) -> void:
	
	# Player reaches the goal
	if body.name == "Player":
		running = false
		
		# Record the best time
		if best_time < 0 or elapsed < best_time:
			best_time = elapsed		# Get the best time
			save_best_time() 		# Save the best time
			update_best_label()		# Update best time lable
			result_label.text = "\nNew best!"	# Display with new best time 
		
		result_panel.visible = true
		result_label.text = "Finished! \n %.2f" % elapsed
		$HUD/ResultPanel/ButtonRow/YesButton.grab_focus()


func update_best_label():
	# Only show Best Time if it exists
	best_label.visible = best_time >= 0
	
	# Set Best Time Label
	if best_time < 0:
		best_label.text = "Best: --"
	else:
		best_label.text = "Best: %.2f" % best_time

# Yes button pressed in menu
func _on_yes_button_pressed() -> void:
	get_tree().reload_current_scene()

# No button pressed in menu
func _on_no_button_pressed() -> void:
	get_tree().quit()
	
# Increase glow gauge when picking up sparkles	
func _on_sparkles_collected(count):
	if revealing: 	# stops function early whenever reveal is aleady happening
		return		# before it updates the gauge or starts another flash
		
	glow_gauge.value = count # set gauge value
	if count >= glow_gauge.max_value:
		reveal_maze()
	
# Reveal the maze with a camera flash
func reveal_maze():
	# Freeze 
	revealing = true # flash shows maze
	running = false  # pauses timer
	$Player.can_move = false # freezes player movement
	
	# Animation for the camera flash
	var tween := create_tween()
	tween.tween_property(sun, "light_energy", 1.5, 0.1) # the flash
	tween.tween_interval(1.25) # maze lit for 3 secs	
	tween.tween_property(sun, "light_energy", 0.0, 0.5) # slow fade to black
	tween.tween_callback(end_reveal)	
	
# Reset things / get things moving after freeze
func end_reveal():
	revealing = false  # maze can't be seen
	running = true 	   # restarts timer
	$Player.can_move = true  # player resumes movement
	glow_gauge.value = 0 	 # resets glow gauge to empty
	$Player.sparkles = 0		 # resets sparkle collected to 0 
	$Player.reset_glow()	# resets the glow the player has

# Save the Best Time
func save_best_time():
	var config := ConfigFile.new()
	config.set_value("level_1", "best_time", best_time)
	config.save(SAVE_PATH)
	
# Load the Saved Best Time
func load_best_time():
	var config := ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	# The last value found in the default
	if err == OK:
		best_time = config.get_value("level_1", "best_time", -1.0)
