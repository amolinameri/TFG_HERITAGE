extends Panel
var tower = preload("res://Defense/arrowTower/arrowTower.tscn")
var validTile

func _on_gui_input(event: InputEvent) -> void: # Per click on the map...
	# if the player has enough gold...
	if GameValues.gold >= GameValues.arrowTowerCost:
		# if grab the tower from the UI is selected...
		if event is InputEventMouseButton and event.button_mask == 1:
			# we create a copy of the arrow tower...
			if not get_tree().root.has_node("copyTower"):
				var auxTower = tower.instantiate()
				auxTower.name = "copyTower"
				# To not making it functional yet, we deactivate her functions
				auxTower.process_mode = Node.PROCESS_MODE_DISABLED
				#We added to the scene
				get_tree().root.add_child(auxTower)
				
				# we make sure is positioned in the same point as the mouse
				auxTower.global_position = auxTower.get_global_mouse_position()

		# Once is selected, it would start moving, following the mouse
		elif event is InputEventMouseMotion and event.button_mask == 1:
			# we get the previous created tower by his name
			var copyTower = get_tree().root.get_node_or_null("copyTower")
			
			if copyTower:
				# we make sure is positioned in the same point as the mouse
				copyTower.global_position = copyTower.get_global_mouse_position()
				# we get the tiles of the map
				var tileMap = get_tree().get_root().get_node("Main/TileMap")
				# and we use it to know the coordinates were we are
				var mouseTile = tileMap.local_to_map(tileMap.to_local(copyTower.global_position))
				
				# we are going to say that, except in specific cases,
				# the positions is going to be valid
				var valid = true
				# The area of this tower is 5 x 5, so, around this area...
				
				for x in range(-2, 3):  
					for y in range(-2, 3): 
						# being the mouse the center, we search in the range
						var tiles = mouseTile + Vector2i(x, y)
						# the only valid tipe of tile is the grass/yellow we are
						# using from the tilesheet for outside the road
						var validtile = tileMap.get_cell_atlas_coords(0, tiles)
						
						# is anything from the 5 x 5 is NOT a validTile
						if validtile != Vector2i(3, 5) and validtile != Vector2i(3, 9):
							valid = false
							break # cannot be place in there
					
					if not valid: break
				# if the are we are going to put the tower is valid
				if valid:
					# now we make a second comprobation
					# if two towers are to close, it would pull one above the
					# other visually, so, if the tower we are going to put,
					# is around another already put on the map, we make it invalid
					var towersContainer = get_tree().get_root().get_node("Main/TowersContainer")
					for towers in towersContainer.get_children():
						# 80 pixels of distance between towers is enough 
						if copyTower.global_position.distance_to(towers.global_position) < 80:
							valid = false
							break
						
				# to make it visual to the player, we would change the color
				# if a place is valid or not
				if valid:
					copyTower.modulate = Color(0, 1, 0, 1)
				else:
					copyTower.modulate = Color(1, 0, 0, 1)
				
				validTile = true if valid else false

		# trow the tower in the map
		elif event is InputEventMouseButton and event.button_mask == 0:
			# trow the tower in the map
			var copyTower = get_tree().root.get_node_or_null("copyTower")
			if copyTower:
				#if is not inside the tileMap or in  a valid tile, then it does
				# not let put on the map
				if event.global_position.x >= 1024 or validTile == false: 
					copyTower.queue_free()
				else:
					# is if valid, we put the tower in the map
					var path = get_tree().get_root().get_node("Main/TowersContainer")
					copyTower.reparent(path)
					copyTower.global_position = copyTower.get_global_mouse_position()
					# the range is hide for visual purposes
					copyTower.get_node("RangeShooting").hide()
					# we start again the functionality of the tower
					copyTower.process_mode = Node.PROCESS_MODE_INHERIT
					copyTower.name = "ArrowTower"
					copyTower.add_to_group("towerArcher")
					# we put the normal colors and rest the cost of the tower
					copyTower.modulate = Color(1, 1, 1, 1)
					GameValues.gold -= GameValues.arrowTowerCost
		else:
			# if there is not enough gold, we make it impossible to grab it
			var copyTower = get_tree().root.get_node_or_null("copyTower")
			if copyTower: 
				copyTower.queue_free()
