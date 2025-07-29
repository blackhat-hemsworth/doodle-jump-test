class_name Player
extends CharacterBody2D

const bounce_impulse = -900
const move_speed = 400
const TERMINAL_VELOCITY = 700
var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
var max_height_reached = 10000
var move_speed_local = 400
var hunger = 0
var angry = false
@onready var screen_size = get_viewport_rect().size
@onready var sprite_2d: Sprite2D = $sprite

signal new_height_reached(new_height: float)
signal die(cause_of_death: String)
signal nutrition(status: String)

func start(pos):
	position = pos
	max_height_reached = position.y
	show()
	$CollisionShape2D.disabled = false
	
func _ready() -> void:
	hide()
	
func _physics_process(delta: float) -> void:
	if angry:
		move_speed_local = move_speed * (randi_range(-5, 15) * (hunger/5) / 5) + move_speed_local * .2
	else:
		move_speed_local = move_speed * (1 + (hunger / 5))  
		
	var direction = Vector2.ZERO
	
	# inputs
	if is_on_floor():
		bounce()
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
		
	# outputs
	if position.y < max_height_reached:
		max_height_reached = position.y
		new_height_reached.emit(max_height_reached)
	
	if hunger < -3:
		die_of_hunger()
	elif hunger > 5:
		angry = true
	elif angry and hunger < 4.5:
		angry = false
		hunger = -1.5
		
	var hunger_bump = delta / 5
	hunger -= hunger_bump
	
	if hunger < -1.5 and hunger + hunger_bump > -1.5:
		nutrition.emit("You need food!")

	velocity.x = direction.x * move_speed_local
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta) # fall
	move_and_slide()
	if velocity.x < 0:
		sprite_2d.flip_h = true
	if velocity.x > 0:
		sprite_2d.flip_h = false
	
	sprite_2d.modulate = Color(max(1, 255 * hunger / 5), 
							   (1 - int(angry))/ abs(hunger)  , 
							   max(1 - int(angry), 255 * -1 * hunger / 5)) 
	print(sprite_2d.modulate)
	position.x = wrapf(position.x, 0, screen_size.x - 100)


func bounce() -> void:
	velocity.y += bounce_impulse

func ate_food() -> void:
	hunger += 1
	if hunger > 5 and hunger - 1 < 5:
		nutrition.emit("SALT CRAZE")
	elif hunger > 4 and hunger - 1 < 4:
		nutrition.emit("Watch your sodium!")

	
# TODO: on body entered for enemies

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	fall_to_death()
	
func fall_to_death() -> void:
	die.emit("You fell to your death")

func die_of_hunger() -> void:
	die.emit("You starved")
	
