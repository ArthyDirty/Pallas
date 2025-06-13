class_name CardAnimator

extends Node2D

var dissolve_card = false
var dissolve_state: float = 0.0
var speed: float = 100.0 / 2.5  # 100 unités en 5 secondes


var card_hidden = true
var card_flip = true

var card
var card_sprite: AnimatedSprite2D
var shadow_sprite: AnimatedSprite2D
var surbrillance_sprite: AnimatedSprite2D


var dissolve_material = preload("res://Divers/Materials/Dissolve.tres").duplicate()


func on_card_loaded() -> void:
	card = get_parent()
	card_sprite = card.card_sprite
	surbrillance_sprite = card.surbrillance_sprite
	shadow_sprite = card.shadow_sprite
	show_card()


func _process(delta: float) -> void:
	if dissolve_card:
		dissolve(delta)


func show_card():
	if card_hidden:
		card_sprite.play("flip")
		card_hidden = false


## Fonctions qui gèrent l'effet de dissolution
func set_dissolve_state(value: float):
	card_sprite.material.set_shader_parameter("dissolve_state", value)
	shadow_sprite.material.set_shader_parameter("dissolve_state", value)

func play_dissolve(fast = false):
	card_sprite.material = dissolve_material
	shadow_sprite.material = dissolve_material
	dissolve_state = 0.0
	set_dissolve_state(dissolve_state)
	if not fast:
		await get_tree().create_timer(0.5).timeout
	if surbrillance_sprite:
		surbrillance_sprite.queue_free()
	dissolve_card = true

func dissolve(delta: float):
	if dissolve_state < 100.0:
		dissolve_state += speed * delta
		dissolve_state = min(dissolve_state, 100.0)
		set_dissolve_state(dissolve_state)
	elif dissolve_state >= 100:
		get_parent().queue_free()
