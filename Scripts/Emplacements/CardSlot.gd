class_name CardSlot

extends Area2D


@onready var slot_sprite: AnimatedSprite2D = $CardSlotSprite

@export var locked_on_place: bool = true

var card_owned: CardManager = null


func place_card(card: CardManager):
	card_owned = card
	slot_sprite.play("default")


func remove_card():
	if locked_on_place:
		return
	else:
		card_owned = null


func free_card_slot():
	card_owned.card_animator.show_card()
	card_owned.card_animator.play_dissolve(true)
	card_owned = null


func on_card_hover(_card: CardManager):
	slot_sprite.play("card_hover")


func on_card_exit(_card: CardManager):
	slot_sprite.play("default")


func is_locked():
	return locked_on_place


func is_free():
	return card_owned == null
