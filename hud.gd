extends CanvasLayer

func show_status_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageLabel/Timer.start()

func show_message(text):
	$GameOverLabel.text = text
	$GameOverLabel.show()

func show_game_over(cause_of_death: String):
	show_message("Game Over :-(\n" + cause_of_death + "\nPress SPACE to retry")

func _on_timer_timeout() -> void:
	$MessageLabel.hide() # Replace with function body.
