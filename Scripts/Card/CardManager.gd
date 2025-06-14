class_name  CardManager

extends Node2D

## Ce script gère les données des cartes et le chargements des sprites

@export var data: CardData = null

@onready var card_sprite: AnimatedSprite2D = $CardSprite
@onready var surbrillance_sprite: AnimatedSprite2D = $SurbrillanceSprite
@onready var shadow_sprite: AnimatedSprite2D = $ShadowSprite
@onready var card_button: Button = $CardButton
@onready var card_movement: CardMovement = $CardMovement
@onready var card_animator: CardAnimator = $CardAnimator

var card_moving = false
var card_hidden = true
var card_placed = false
var card_selectable = true

var mouse_hover = true


func _ready():
	if data == null:
		print("Pas de CardData assignée")
		return
	_load_sprite_frames()
	card_animator.on_card_loaded()


func _process(_delta: float) -> void:
	mouse_hover = card_button.get_rect().has_point(to_local(get_global_mouse_position()))


func _load_sprite_frames():
	var frames = load(data.sprite_frames_path)
	var surbrillance_frames = load(data.surbrillance_sprite_frames_path)

	if frames == null:
		print("Impossible de charger SpriteFrames depuis ", data.sprite_frames_path)
		return
	if surbrillance_frames == null:
		print("Impossible de charger Surbrillance depuis ", data.surbrillance_sprite_frames_path)
		return

	card_sprite.frames = frames


func set_card_data(card_data: CardData) -> void:
	data = card_data
	if card_sprite:
		_load_sprite_frames()


func _on_card_moving(state: Variant) -> void:
	card_moving = state


func _on_card_flip() -> void:
	card_hidden = not card_hidden


func _on_card_selectable(state: Variant) -> void:
	card_selectable = state
