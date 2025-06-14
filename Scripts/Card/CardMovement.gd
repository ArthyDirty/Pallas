class_name CardMovement

extends Area2D
## Ce script gère tout ce qui concerne les interactions entre le joueur et la carte

# === Références ===
var card: CardManager = null

# === États internes liés au déplacement ===
var card_clicked = false
var can_move = true

# === Données de déplacement ===
var card_slot_hover = false
var card_slot_pos
var card_slot: CardSlot
var last_card_slot: CardSlot
var last_pos
var dif_pos

# === Signaux ===
signal state_changed(state)


func _ready() -> void:
	card = get_parent()
	last_pos = card.global_position


func _process(_delta):
	can_move = false if card.data.current_state == CardStates.CardState.PLACED else true
	if card_clicked and can_move:
		_drag_card()


func _drag_card():
	var mouse_pos = get_viewport().get_mouse_position()
	card.global_position = mouse_pos + dif_pos


func _on_card_button_down():
	if can_move:
		state_changed.emit("moving")
		card_clicked = true
		last_pos = card.global_position
		dif_pos = card.global_position - get_viewport().get_mouse_position()
		card.z_index = 5


func _on_card_button_up():
	if can_move:
		card_clicked = false
		card.z_index = 3

		if card_slot_hover:
			_place_card_with_animation()
		else:
			_return_to_last_position()


func _place_card_with_animation():
	var tween = create_tween()
	tween.tween_property(card, "global_position", card_slot_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(0.4).timeout
	
	if last_card_slot and last_card_slot != card_slot:
		last_card_slot.remove_card()
		
	card_slot.place_card(card)
	
	last_card_slot = card_slot
	
	if card_slot.is_locked():
		state_changed.emit("placed")
	else:
		state_changed.emit("idle")


func _return_to_last_position():
	var distance = card.global_position.distance_to(last_pos)
	var duration = distance / 3000.0
	var overshoot = (card.global_position - last_pos) * 0.01
	var overshoot_pos = last_pos - overshoot

	var tween = create_tween()
	tween.tween_property(card, "global_position", overshoot_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "global_position", last_pos, duration/4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(duration + duration/4).timeout
	state_changed.emit("idle")


func _on_card_slot_hover(slot: CardSlot):
	if slot.is_free() and card_clicked:
		card_slot_hover = true
		card_slot_pos = slot.global_position
		card_slot = slot
		card_slot.on_card_hover(card)


func _on_card_slot_exit(card_slot: CardSlot):
	card_slot_hover = false
	card_slot.on_card_exit(card)
