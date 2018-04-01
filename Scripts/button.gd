extends Spatial

func _ready():
	get_node("Area").connect("body_entered", self, "collided")
	set_physics_process(true)
	pass

var hit_something = false
var enabled = false

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func collided(body):
	if hit_something == false:
		enabled = true
		
	hit_something = true