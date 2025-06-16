extends HBoxContainer

@onready var card_icon: TextureRect = $CardIcon
@onready var draw_chance_label: Label = $DrawChance

func setup(texture: Texture2D, name: String, chance: float):
	card_icon.texture = texture
	draw_chance_label.text = "%s %" % chance
