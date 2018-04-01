extends Node

var roomlist2x2 = []
var roomlist4x4 = []
var corridorlist = []
var room_coordinates = {}

var gen_debug = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var pool = preload("res://Objects/Rooms/RoomsAndCorridors.scn")
	var pool_node = pool.instance()
	#var path = pool.get_state().get_node_path(0)
	#getallnodes(get_node(path.get_name(0)))
	getallnodes(pool_node)
	generateScene()
	pass

func getallnodes(node):
	for N in node.get_children():
		var node_name = N.get_name()
		if N.get_child_count() > 0:
			if (gen_debug):
				print("["+node_name+"]")
			if "corridor" in node_name:
				corridorlist.append(N)
				if (gen_debug):
					print("Added ["+node_name+"] to corridorlist")
			elif "room" in node_name:
				#roomlist.append(N)
				#print("Added ["+node_name+"] to roomlist")
				
				if "2x2" in node_name:
					roomlist2x2.append(N)
				if "4x4" in node_name:
					roomlist4x4.append(N)

			getallnodes(N)
		else:
			# Do something
			if (gen_debug):
				print("- "+node_name)

func loadAllAssets():
	var dir = Directory.new()
	if dir.open("res://Objects/Rooms") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				if (gen_debug):
					print("Found directory: " + file_name)
			else:
				if (gen_debug):
					print("Found file: " + file_name)
			file_name = dir.get_next()

var position = Vector3(0,0,0)
var prev_pos = Vector3(0,0,0)
var direction_offset_cor = Vector3(0,0,0)
var direction_offset_room = Vector3(0,0,0)
var rotation_offset = 0
var size_offset = 8 #default 2x2
var roomlist = null
var direction = 0
var previous_room_offset = 8 #default 2x2
var proposed_coord = null
var proposed_coord_abs = null
var proposed_placement = null
var root = null

#Based on SDL_HasIntersection, thanks!
func intersects2(A,B):
	var Amin
	var Amax
	var Bmin
	var Bmax
	#Horizontal intersection
	Amin = A["x"]
	Amax = Amin + A["w"]
	Bmin = B["x"]
	Bmax = Bmin + B["w"];
	if (Bmin > Amin):
		Amin = Bmin
	if (Bmax < Amax):
		Amax = Bmax
	if (Amax <= Amin):
		if (gen_debug):
			print("noops")
		return false

	#Vertical intersection
	Amin = A["y"]
	Amax = Amin + A["h"]
	Bmin = B["y"]
	Bmax = Bmin + B["h"]
	if (Bmin > Amin):
		Amin = Bmin
	if (Bmax < Amax):
		Amax = Bmax
	if (Amax <= Amin):
		if (gen_debug):
			print("noops")
		return false
	
	if (gen_debug):
		print("yups")
	return true

func intersects(position, room):
	var min_distance = 1
	var closest_object = null
	var closest_coordinate = Vector3()
	var shortest_dist = 65536
	for B in room_coordinates:
		var dist = position.distance_to( B )
		if dist < shortest_dist:
			shortest_dist = dist
			closest_coordinate = B
			closest_object = room_coordinates[B]; 
	
	if (closest_object):
		var A = {}
		A["x"] = position.x - room.scale.x #Add half scale to move top-left to center comparison
		A["y"] = position.z - room.scale.z
		A["w"] = room.scale.x*2
		A["h"] = room.scale.z*2
	
		var B = {}
		B["x"] = closest_coordinate[0] - closest_object.scale.x #x
		B["y"] = closest_coordinate[2] - closest_object.scale.z #z
		B["w"] = closest_object.scale.x*2
		B["h"] = closest_object.scale.z*2
		if (gen_debug):
			print ("Pr: ", A, " - Existing: ", B)
		return intersects2(A,B)
	else: 
		return false

func recalculate_room_size(size):
	if (size == 0): #2x2
		roomlist = roomlist2x2
	elif (size == 1): #4x4
		roomlist = roomlist4x4

	size_offset = roomlist[0].scale.x
	#print(size_offset)
	var prev_room = room_coordinates[prev_pos]
	if (gen_debug):
		print("|prev_offset ",previous_room_offset," prev_room ",prev_room.scale.x)
	
	#var corridor_offset = previous_room_offset + 8

	var corridor_offset = prev_room.scale.x + 8
	var room_offset = size_offset + 8
	#print("Corridor = "+str(corridor_offset)+" room_offset = "+str(room_offset))
	
	if (direction == 0):
		direction_offset_cor = Vector3(corridor_offset,0,0)
		direction_offset_room = Vector3(room_offset,0,0)
		rotation_offset = deg2rad(90)
		proposed_coord = position+(direction_offset_cor+direction_offset_room)
		proposed_coord_abs = proposed_coord + Vector3(8,0,0) #compensate for corridor
	elif (direction == 1):
		direction_offset_cor = Vector3(0,0,corridor_offset)
		direction_offset_room = Vector3(0,0,room_offset)
		proposed_coord = position+(direction_offset_cor+direction_offset_room)
		proposed_coord_abs = proposed_coord + Vector3(0,0,8) #compensate for corridor
		rotation_offset = deg2rad(0)
	elif (direction == 2):
		direction_offset_cor = Vector3(corridor_offset,0,0)
		direction_offset_room = Vector3(room_offset,0,0)
		rotation_offset = deg2rad(-90)
		proposed_coord = position-(direction_offset_cor+direction_offset_room)
		proposed_coord_abs = proposed_coord + Vector3(8,0,0) #compensate for corridor
	else:
		direction_offset_cor = Vector3(0,0,corridor_offset)
		direction_offset_room = Vector3(0,0,room_offset)
		rotation_offset = deg2rad(0)
		proposed_coord = position-(direction_offset_cor+direction_offset_room)
		proposed_coord_abs = proposed_coord + Vector3(0,0,8) #compensate for corridor

func reverse_room():
	#debug
	#var db = get_node("debug_cube").duplicate()
	#db.set_translation(position)
	#root.call_deferred("add_child", db)
	
	position = prev_pos#-(direction_offset_cor+direction_offset_room)
	#debug
	#var db2 = get_node("debug_cube2").duplicate()
	#db2.set_translation(position)
	#root.call_deferred("add_child", db2)
	
	prev_pos = position

func new_seed():
    randomize()
    var random_seed = str(randi())
    seed(random_seed.hash())
    return random_seed

func generateScene():
	root = get_tree().get_root()
	#Seeded
	#var random_seed = global.levelseed
	#seed(random_seed.hash())
	#Non-Seeded
	global.levelseed = new_seed()

	room_coordinates[Vector3(0,0,0)] = get_node("playerspawn") #Add start room to list
	previous_room_offset = 8 #default 2x2
	for x in range(0, 20):
		direction = randi() % 4
		var size = randi() % 2
		roomlist = null

		recalculate_room_size(size)
		var proposed_allowed = false

		#if the proposed location is already in use, reverse the step and try again
		if (proposed_coord in room_coordinates):
			reverse_room()
		else:
			#check if there is a size collision for the new room			
			if (!room_coordinates.empty()):
				while (size >= 0):		
					if (intersects(proposed_coord,roomlist[0])):
						size -= 1
						recalculate_room_size(size)
					else:
						proposed_allowed = true
						break
				if (proposed_allowed == false):
					reverse_room()
			else:
				proposed_allowed = true
		
		if (proposed_allowed):
			#Corridors
			if (direction == 0 or direction == 1):
				position = position + Vector3(0,2,0) + direction_offset_cor
			else:
				position = position + Vector3(0,2,0) - direction_offset_cor
			var cor = corridorlist[randi() % corridorlist.size()].duplicate()
			cor.rotate(Vector3(0,1,0), rotation_offset)
			cor.set_translation(position)
			root.call_deferred("add_child", cor)

			#Rooms
			if (direction == 0 or direction == 1):
				position = position + Vector3(0,-2,0) + direction_offset_room
			else:
				position = position + Vector3(0,-2,0) - direction_offset_room
			if (gen_debug):
				print ("Placed: Position = " + str(position) + " - Position Proposed = ", str(proposed_coord))
			var room = roomlist[randi() % roomlist.size()].duplicate()
			#print(room)
			room.set_translation(position)
			room_coordinates[position] = room
			root.call_deferred("add_child", room)
			
			prev_pos = position
		previous_room_offset = size_offset