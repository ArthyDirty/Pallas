class_name  CardManager

extends Node2D

## Ce script gère les données des cartes et le chargements des sprites

var data: CardData = null

@onready var card_sprite: AnimatedSprite2D = $CardSprite
@onready var surbrillance_sprite: AnimatedSprite2D = $SurbrillanceSprite
@onready var shadow_sprite: AnimatedSprite2D = $ShadowSprite
@onready var card_button: Button = $CardButton
@onready var card_movement: CardMovement = $CardMovement
@onready var card_animator: CardAnimator = $CardAnimator


func _ready():
	if data == null:
		print("Pas de CardData assignée")
		return
	_load_sprite_frames()
	card_animator.on_card_loaded()


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
