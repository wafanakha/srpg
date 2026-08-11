extends Button

@onready var normal_button = preload("res://Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/SmallBlueRoundButton_Regular.png")
@onready var pressed_button = preload("res://Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/SmallBlueRoundButton_Pressed.png")

var down = true

func _ready() -> void:
	icon = normal_button
	pass 


func _process(delta: float) -> void:
	pass



func _on_button_down() -> void:
	icon = pressed_button

	pass 


func _on_button_up() -> void:
	icon = normal_button
	pass 
