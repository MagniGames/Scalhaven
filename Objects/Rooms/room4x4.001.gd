extends MeshInstance

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	#Spawn a weapon
	var pickups = preload("res://Objects/Pickups/Pickups.tscn").instance()
	#var chosen_pickup = null
	var choice = randi() % pickups.get_child(0).get_child_count()
	#print(pickups.get_child(0).get_name())
	get_node("weaponpoint").add_child(pickups.get_child(0).duplicate())
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
