class_name PlaySlot

extends CardSlot


@export var emp_col = 0
@export var emp_row = 0

signal card_placed(emp_col, emp_row, card, card_name, emplacement)


func get_col():
	return emp_col


func get_row():
	return emp_row


func place_card(card: CardManager):
	card_owned = card
	slot_sprite.play("default")
	card_placed.emit(emp_col, emp_row, card, card.data.name , self)
