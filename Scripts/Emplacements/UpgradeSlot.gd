extends CardSlot


@export var new_damage: int = 0
@export var new_mult: int = 1


func _on_button_up() -> void:
	if card_owned:
		card_owned.upgrade_card(new_damage, new_mult)
