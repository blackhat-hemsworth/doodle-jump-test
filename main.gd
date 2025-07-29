extends Node2D

@export var platform_scene: PackedScene
@export var food_scene: PackedScene

var highest_platform = 268 # create other platforms programmatically??
@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	new_game()

func _process(delta: float) -> void:
	if $Player.position.y < $camera.position.y:
		$camera.position.y = $Player.position.y
		if platform_needed():
			spawn_top() 

func platform_needed() -> bool:
	if randi_range(1,50) == 12:
		return true 
	elif highest_platform > $camera.position.y - (screen_size.y / 2) + 400:
		return true
	else:
		return false

func spawn_top() -> void:
	var new_platform = platform_scene.instantiate()
	new_platform.position = Vector2(randi_range(0,1000), $camera.position.y - (screen_size.y / 2) + 100 ) 
	highest_platform = new_platform.position.y
	add_child(new_platform)
	
	if randi_range(1,2) == 2:
		var new_treat = food_scene.instantiate()
		new_treat.position = new_platform.position + Vector2(0,-40)
		add_child(new_treat)
	

func new_game() -> void:
	$Player.start($Player.position)	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $HUD/GameOverLabel.visible:
		get_tree().reload_current_scene()

func game_over(cause_of_death: String) -> void:
	$HUD.show_game_over(cause_of_death)
	get_tree().call_group("platform", "queue_free")
	# TODO: clean up platforms -- maybe platform script?

func _on_player_die(cause_of_death: String) -> void:
	game_over(cause_of_death)
	
func _on_player_nutrition(status: String) -> void:
	$HUD.show_status_message(status)
