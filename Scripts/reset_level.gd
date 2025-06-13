class_name Reset

extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _on_button_down() -> void:
	animated_sprite_2d.play("pushed")


func _on_button_up() -> void:
	GameData.reset_level()
