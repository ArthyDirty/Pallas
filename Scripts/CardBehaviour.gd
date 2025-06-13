class_name CardInteraction

extends Node2D
## Ce script gère tout ce qui concerne les interactions entre le joueur et la carte

# === États internes liés au déplacement ===
var card_clicked = false
var can_move = true
var shadow_follow = false

# === Données de déplacement ===
var emplacement_hover = false
var emplacement_pos
var last_emplacement
var last_pos
var dif_pos

# === Références utiles ===
@onready var card: Card = $"."  # Référence à soi-même
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var card_button: Button = $CardButton


# ============================================================
# ============= Déplacement de la carte ======================
# ============================================================

func _process(_delta):
	if card_clicked and can_move:
		_drag_card()

	if shadow_follow:
		shadow.position = card.global_position * 0.2 * Vector2(-1,-1)


func _drag_card():
	var mouse_pos = get_viewport().get_mouse_position()
	card.global_position = mouse_pos + dif_pos


# ============================================================
# ============= Événements souris ============================
# ============================================================

func _on_card_button_down():
	if can_move:
		card_clicked = true
		last_pos = card.global_position
		dif_pos = card.global_position - get_viewport().get_mouse_position()
		card.z_index = 5
		shadow.visible = true
		shadow_follow = true


func _on_card_button_up():
	if can_move:
		card_clicked = false
		card.z_index = 3

		if last_emplacement:
			last_emplacement.animated_sprite.play("default")

		if emplacement_hover:
			_place_card_with_animation()
		else:
			_return_to_last_position()


# ============================================================
# ============= Placement / Retour ===========================
# ============================================================

func _place_card_with_animation():
	var distance = card.global_position.distance_to(emplacement_pos)
	var duration = distance / 100
	var overshoot = (card.global_position - emplacement_pos) * 0.02
	var overshoot_pos = emplacement_pos - overshoot

	var tween = create_tween()
	tween.tween_property(card, "global_position", emplacement_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shadow, "position", Vector2.ZERO, duration/4).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(duration + duration/2).timeout
	shadow.visible = false
	last_emplacement.place_card(self)
	can_move = false


func _return_to_last_position():
	var distance = card.global_position.distance_to(last_pos)
	var duration = distance / 3000.0
	var overshoot = (card.global_position - last_pos) * 0.01
	var overshoot_pos = last_pos - overshoot

	var tween = create_tween()
	tween.tween_property(card, "global_position", overshoot_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "global_position", last_pos, duration/4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(duration).timeout
	shadow_follow = false
	tween = create_tween()
	tween.tween_property(shadow, "position", Vector2.ZERO, duration/4).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(duration/2).timeout
	shadow.visible = false


# ============================================================
# ============= Interaction avec l’emplacement ===============
# ============================================================

func _on_emplacement_entered(emplacement: Emplacement):
	if emplacement.is_free() and card_clicked:
		emplacement_hover = true
		emplacement.animated_sprite.play("card_hover")
		emplacement_pos = emplacement.global_position
		last_emplacement = emplacement

func _on_emplacement_exited(emplacement):
	emplacement_hover = false
	emplacement.animated_sprite.play("default")
