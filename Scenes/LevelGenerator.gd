extends Node

var roomlist2x2 = []
var roomlist4x4 = []
var corridorlist = []
var room_coordinates = {}

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
			print("["+node_name+"]")
			if "corridor" in node_name:
				corridorlist.append(N)
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
			print("- "+node_name)

func loadAllAssets():
	var dir = Directory.new()
	if dir.open("res://Objects/Rooms") == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while (file_name != ""):
            if dir.current_is_dir():
                print("Found directory: " + file_name)
            else:
                print("Found file: " + file_name)
            file_name = dir.get_next()

var position = Vector3(0,0,0)
var direction_offset_cor = Vector3(0,0,0)
var direction_offset_room = Vector3(0,0,0)
var rotation_offset = 0
var size_offset = 16 #default 2x2
var roomlist = null
var direction = 0
var previous_room_offset = 16 #default 2x2
var proposed_coord = null
var proposed_coord_abs = null
var proposed_placement = null
		
func recalculate_room_size(size):
	if (size == 0): #2x2
		size_offset = 16
		roomlist = roomlist2x2
	elif (size == 1): #4x4
		size_offset = 32 - 8 #compensate for half of the size of the corridor?
		roomlist = roomlist4x4
	
	if (direction == 0):
		direction_offset_cor = Vector3(previous_room_offset,0,0)
		direction_offset_room = Vector3(size_offset,0,0)
		rotation_offset = deg2rad(90)
	elif (direction == 1):
		direction_offset_cor = Vector3(0,0,previous_room_offset)
		direction_offset_room = Vector3(0,0,size_offset)
		rotation_offset = deg2rad(0)
	elif (direction == 2):
		direction_offset_cor = Vector3(-previous_room_offset,0,0)
		direction_offset_room = Vector3(-size_offset,0,0)
		rotation_offset = deg2rad(-90)
	else:
		direction_offset_cor = Vector3(0,0,-previous_room_offset)
		direction_offset_room = Vector3(0,0,-size_offset)
		rotation_offset = deg2rad(0)
		
	proposed_coord = position+(direction_offset_cor+direction_offset_room)
	proposed_coord_abs = proposed_coord + direction_offset_cor + direction_offset_room
	proposed_placement = AABB(proposed_coord_abs,roomlist[0].get_aabb().size)

func generateScene():
	var root = get_tree().get_root()
	#Seeded
	#var random_seed = "itsarandomizerseed"
	var random_seed = "lamasarecool"
	seed(random_seed.hash())
	#Non-Seeded
	#randomize()

	previous_room_offset = 16 #default 2x2
	for x in range(0, 10):
		direction = randi() % 4
		var size = randi() % 2
		roomlist = null
		size_offset = 16 #default 2x2

		if (size == 0): #2x2
			size_offset = 16
			roomlist = roomlist2x2
		elif (size == 1): #4x4
			size_offset = 32 - 8 #compensate for half of the size of the corridor?
			roomlist = roomlist4x4
		
		if (direction == 0):
			direction_offset_cor = Vector3(previous_room_offset,0,0)
			direction_offset_room = Vector3(size_offset,0,0)
			rotation_offset = deg2rad(90)
		elif (direction == 1):
			direction_offset_cor = Vector3(0,0,previous_room_offset)
			direction_offset_room = Vector3(0,0,size_offset)
			rotation_offset = deg2rad(0)
		elif (direction == 2):
			direction_offset_cor = Vector3(-previous_room_offset,0,0)
			direction_offset_room = Vector3(-size_offset,0,0)
			rotation_offset = deg2rad(-90)
		else:
			direction_offset_cor = Vector3(0,0,-previous_room_offset)
			direction_offset_room = Vector3(0,0,-size_offset)
			rotation_offset = deg2rad(0)
		
		proposed_coord = position+(direction_offset_cor+direction_offset_room)
		proposed_coord_abs = proposed_coord + direction_offset_cor + direction_offset_room
		proposed_placement = AABB(proposed_coord_abs,roomlist[0].get_aabb().size)
		var proposed_allowed = false

		#if the proposed location is already in use, reverse the step and try again
		if (proposed_coord in room_coordinates):
			position += (direction_offset_cor+direction_offset_room)
		else:
			#check if there is a size collision for the new room			
			if (!room_coordinates.empty()):
				for key in room_coordinates:
					print("Room to check ", room_coordinates[key], "- Proposed Room ", proposed_placement)
					if (room_coordinates[key].intersects(proposed_placement)):
						if (size < 0):
							position += (direction_offset_cor+direction_offset_room)
							proposed_allowed = false
							break
						else:
							recalculate_room_size(size)
							size -= 1
					else:
						proposed_allowed = true
						break
			else:
				proposed_allowed = true

		if (proposed_allowed):
			#Corridors
			position = position + Vector3(0,2,0) + direction_offset_cor
			var cor = corridorlist[randi() % corridorlist.size()].duplicate()
			cor.rotate(Vector3(0,1,0), rotation_offset)
			cor.set_translation(position)
			root.call_deferred("add_child", cor)

			#Rooms
			position = position + Vector3(0,-2,0) + direction_offset_room
			var room = roomlist[randi() % roomlist.size()].duplicate()
			print(room)
			room.set_translation(position)
			room_coordinates[position] = room.get_aabb()
			root.call_deferred("add_child", room)
		
		previous_room_offset = size_offset