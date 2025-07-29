class_name Food
extends Area2D


func _on_food_entered(body: Node2D) -> void:
	(body as Player).ate_food()
	queue_free()
