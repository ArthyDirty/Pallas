extends Area2D
class_name Card

# === Données et références ===
var data: CardData

@onready var card: Card = $"."  # Référence à soi-même (peu utile ici)
@onready var card_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var surbrillance_animated_sprite: AnimatedSprite2D = $SurbrillanceAnimatedSprite
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var card_button: Button = $CardButton


# === États internes ===
var card_clicked = false
var card_placed = false
var card_hidden = false
var hide = false
var can_move = true
var card_moving = false
var shadow_follow = false
var selectable = false

# === Données de placement ===
var emplacement_hover = false
var emplacement_pos
var last_emplacement
var last_pos
var dif_pos
var mouse_hover = false

# === Signaux ===
signal card_flipped(card)


# ============================================================
# ============= 1. Initialisation et chargement ==============
# ============================================================

func _ready():
	last_pos = card.global_position
	if data == null:
		print("Pas de CardData assignée")
		return

	_load_sprite_frames()

	if !card_hidden:
		can_move = false
		card_animated_sprite.play("flip")
		await card_animated_sprite.animation_finished
		can_move = true
		
		card_flipped.emit(card)
	else:
		card_animated_sprite.play("hidden")
	


func _load_sprite_frames():
	var frames = load(data.sprite_frames_path)
	var surbrillance_frames = load(data.surbrillance_sprite_frames_path)

	if frames == null:
		print("Impossible de charger SpriteFrames depuis ", data.sprite_frames_path)
		return
	if surbrillance_frames == null:
		print("Impossible de charger Surbrillance depuis ", data.surbrillance_sprite_frames_path)
		return

	card_animated_sprite.frames = frames
	surbrillance_animated_sprite.frames = surbrillance_frames


# ============================================================
# ============= 2. Déplacement de la carte ===================
# ============================================================

func _process(_delta):
	if card_clicked and not card_placed and can_move:
		_drag_card()
	
	if surbrillance_animated_sprite:
		if selectable:
			surbrillance_animated_sprite.play("surbrillance")
		elif not can_move or card_moving or card_placed or !card_button.get_rect().has_point(to_local(get_global_mouse_position())):
			surbrillance_animated_sprite.play("default")
		else:
			surbrillance_animated_sprite.play("surbrillance")
	
	
	if card_placed and hide:
		card_animated_sprite.play("hide")
		card_hidden = true
		hide = false
	
	if shadow_follow:
		shadow.position = card.global_position * 0.2 * Vector2(-1,-1)
	

func _drag_card():
	var mouse_pos = get_viewport().get_mouse_position()
	card.global_position = mouse_pos + dif_pos
	


# ============================================================
# ============= 3. Événements souris =========================
# ============================================================

func _on_card_button_down():
	if not can_move or card_placed:
		return
	card_clicked = true
	last_pos = card.global_position
	dif_pos = card.global_position - get_viewport().get_mouse_position()
	card.z_index = 5
	shadow.visible = true
	shadow_follow = true
	card_moving = true


func _on_card_button_up():
	if card_placed:
		PowerManager.on_card_clicked(self)
	
	if not can_move or card_placed:
		return
	card_clicked = false
	card.z_index = 3
	
	if last_emplacement:
		last_emplacement.animated_sprite.play("default")
	
	if emplacement_hover:
		_place_card_with_animation()
	else:
		_return_to_last_position()


func _on_card_button_mouse_entered():
	pass


func _on_card_button_mouse_exited():
	pass


# ============================================================
# ============= 4. Placement / Retour ========================
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
	card_placed = true
	card_moving = false


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
	card_moving = false
	


# ============================================================
# ============= 5. Interaction avec l’emplacement ============
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


# ============================================================
# ============= 6. Fonctions publiques =======================
# ============================================================

func hide_card_on_draw():
	card_hidden = true

func hide_card():
	if !card_hidden:
		hide = true

func show_card():
	hide = false
	if card_hidden:
		card_animated_sprite.play("flip")
		card_hidden = false
		

func burn_card():
	pass


# ============================================================
# ============= 7. Setter pour les données ===================
# ============================================================

func set_card_data(card_data: CardData) -> void:
	data = card_data
	if card_animated_sprite:
		_load_sprite_frames()
