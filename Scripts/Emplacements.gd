class_name Emplacement

extends Area2D

@onready var emplacement_sprite: AnimatedSprite2D = $EmplacementSprite


@export var emp_col = 0
@export var emp_row = 0

var card_owned: CardManager = null

signal card_placed(emp_col, emp_row, card, card_name, emplacement)


func get_col():
	return emp_col
	
func get_row():
	return emp_row


func place_card(card: CardManager):
	card_owned = card
	emplacement_sprite.play("default")
	card_placed.emit(emp_col, emp_row, card, card.data.name , self)


func free_emplacement():
	card_owned.card_animator.show_card()
	card_owned.card_animator.play_dissolve(true)
	card_owned = null


func is_free():
	if card_owned == null:
		return true
	else:
		return false
