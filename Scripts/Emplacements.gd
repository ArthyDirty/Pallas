class_name Emplacement

extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export var emp_col = 0
@export var emp_row = 0

var card_owned = null

signal card_placed(emp_col, emp_row, card, card_name, emplacement)


func get_col():
	return emp_col
	
func get_row():
	return emp_row


func place_card(card: Card):
	card_owned = card
	animated_sprite.play("default")
	card_placed.emit(emp_col, emp_row, card, card.data.name , self)


func free_emplacement():
	card_owned.show_card()
	card_owned.get_child(0).play_dissolve(true)
	card_owned = null


func is_free():
	if card_owned == null:
		return true
	else:
		return false
