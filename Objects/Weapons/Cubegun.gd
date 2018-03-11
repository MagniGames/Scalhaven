extends Spatial

var bullet_scene = preload("res://Objects/Projectiles/default_cube.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var gun_aim_point_pos = get_node("Firetarget").global_transform.origin
	get_node("Firepoint").look_at(gun_aim_point_pos, Vector3(0, 1, 0))
	get_node("Firepoint").rotate_object_local(Vector3(0, 1, 0), deg2rad(180))
	pass

func fire_bullet():
	# Pistol bullet handling: Spawn a bullet object!
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	
	clone.global_transform = get_node("Firepoint").global_transform
	# The bullet is a little too small (by default), so let's make it bigger!
	#clone.scale = Vector3(4, 4, 4)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
