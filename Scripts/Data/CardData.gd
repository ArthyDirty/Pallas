class_name CardData

extends Resource


@export var name: CardNames.CardName = CardNames.CardName.BLANK
@export var power_type: PowerTypes.PowerType = PowerTypes.PowerType.NONE
@export var damage : int = 0
@export var mult : int = 1
@export var sprite_frames_path: String = "res://Sprites/Sprite frames/blank_card_sprite_frames.tres"
@export var surbrillance_sprite_frames_path: String = "res://Sprites/Sprite frames/surbrillance_sprite_frames.tres"
@export var current_state : CardStates.CardState = CardStates.CardState.IDLE
@export var hidden_state : bool = true


func change_damage(new_damage):
	damage = new_damage


func change_mult(new_mult):
	mult = new_mult


func duplicate_data() -> CardData:
	var new_data = CardData.new()
	new_data.name = self.name
	new_data.power_type = self.power_type
	new_data.damage = self.damage
	new_data.sprite_frames_path = self.sprite_frames_path
	new_data.surbrillance_sprite_frames_path = self.surbrillance_sprite_frames_path
	new_data.current_state = self.current_state
	new_data.hidden_state = self.hidden_state
	return new_data
