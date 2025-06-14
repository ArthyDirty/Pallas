class_name CardMovement

extends Area2D
## Ce script gère tout ce qui concerne les interactions entre le joueur et la carte

# === Références ===
var card: CardManager = null

# === États internes liés au déplacement ===
var card_clicked = false
var can_move = true

# === Données de déplacement ===
var emplacement_hover = false
var emplacement_pos
var last_emplacement
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

		if emplacement_hover:
			_place_card_with_animation()
		else:
			_return_to_last_position()


func _place_card_with_animation():
	var tween = create_tween()
	tween.tween_property(card, "global_position", emplacement_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(0.4).timeout
	last_emplacement.place_card(card)
	
	state_changed.emit("placed")


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


func _on_emplacement_entered(emplacement: Emplacement):
	if emplacement.is_free() and card_clicked:
		emplacement_hover = true
		emplacement_pos = emplacement.global_position
		last_emplacement = emplacement


func _on_emplacement_exited(_emplacement: Emplacement):
	emplacement_hover = false
