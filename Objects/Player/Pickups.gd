extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Area").connect("body_entered", self, "collided")
	set_physics_process(true)
	pass

var counter = 0
var up = true
var hit_something = false

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.

	if (up):
		translate(Vector3(0,0.01,0))
	else:
		translate(Vector3(0,-0.01,0))

	if (counter == 50):
		up = !up
		counter = 0
	
	counter += 1
	
	rotate(Vector3(0,1,0), deg2rad(1))
	pass

func collided(body):
    if hit_something == false:
        if body.has_method("player_pickup"):
            body.player_pickup(get_name(), 1)

    hit_something = true
    queue_free()