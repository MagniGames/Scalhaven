extends LinkButton
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _on_LinkButton_pressed():
	get_tree().change_scene("res://Scenes/TestScene1.tscn")

func _on_ThemeList_item_selected( index ):
	#global.theme_to_load = get_node("../ThemeList").get_item_text(index)
	pass # replace with function body