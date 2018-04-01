extends MeshInstance

var timer
var player

func _ready():
	get_node("Area").connect("body_entered", self, "collided")
	set_physics_process(true)
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout")
	timer.set_wait_time(20)
	timer.set_one_shot(false)
	add_child(timer)
	pass

var counter = 0
var hit_something = false
var completed = false
var disapear = -1

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if player:
		player.get_node("UI/Objective/objective-timer").text = str(round(timer.time_left))
		
	if 	((get_node("Button1").enabled == true) and 
		(get_node("Button2").enabled == true) and
		(get_node("Button3").enabled == true)):
		completed = true
		
	if ((completed == true) and (disapear < 0)):
		timer.stop()
		player.get_node("UI/Objective/objective-text").text = "Finished"
		disapear = 1
	
	if (disapear > 0):
		disapear += 1
	if (disapear == 200):
		player.get_node("UI/Objective").set_visible(false)
		disapear = 0

	pass

func collided(body):
	if hit_something == false:
		player = body
		body.get_node("UI/Objective").set_visible(true)
		body.get_node("UI/Objective/objective-text").text = "Disable the 3 buttons before the timer runs out"
		timer.start()

	hit_something = true
	#queue_free()
	
func _on_timer_timeout():
	player.get_node("UI/Objective").set_visible(false)
	player.get_node("UI/Objective/objective-text").text = "Placeholder"
	pass
   #your_timer_stuff()