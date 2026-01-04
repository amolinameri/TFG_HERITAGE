extends Panel
var spike = preload("res://Defense/spike/spikes.tscn")
var validTile

func _on_gui_input(event: InputEvent) -> void: # Per click on the map...
	# if the player has enough money for the spike...
	if GameValues.gold >=  GameValues.spikeCost:
		# if grab the tower from the UI is selected...
		if event is InputEventMouseButton and event.button_mask == 1:
			# we create a copy of the spike...
			if not get_tree().root.has_node("copySpike"):
				var auxSpike = spike.instantiate()
				auxSpike.name = "copySpike"
				# To not making it functional yet, we deactivate her functions
				auxSpike.process_mode = Node.PROCESS_MODE_DISABLED
				#We added to the scene
				get_tree().root.add_child(auxSpike)
				
				# we make sure is positioned in the same point as the mouse
				auxSpike.global_position = auxSpike.get_global_mouse_position()

		# Once is selected, it would start moving, following the mouse
		elif event is InputEventMouseMotion and event.button_mask == 1:
			# we get the previous created spikes by his name
			var copySpike = get_tree().root.get_node_or_null("copySpike")
			
			if copySpike:
				# we make sure is positioned in the same point as the mouse
				copySpike.global_position = copySpike.get_global_mouse_position()
				# we get the tiles of the map
				var tileMap = get_tree().get_root().get_node("Main/TileMap")
				# and we use it to know the coordinates were we are
				var mouseTile = tileMap.local_to_map(tileMap.to_local(copySpike.global_position))
				
				# we are going to say that, except in specific cases,
				# the positions is going to be valid
				var valid = true
				# The area of this element is is 4 x 4, so, around this area...
				
				for x in range(-1, 2):
					for y in range(-1, 2):
						# being the mouse the center, we search in the range
						var tiles = mouseTile + Vector2i(x, y)
						# the only valid tipe of tile is the brown we are
						# using from the tilesheet for the roads
						var validtile = tileMap.get_cell_atlas_coords(0, tiles)
						# is anything from the 3 x 3 is NOT a validTile
						if validtile != Vector2i(3, 11):
							valid = false
							break # cannot be place in there
					
					if not valid: break
				if valid:
					# now we make a second comprobation
					# if two spikes are to close, it would pull one above the
					# other visually, so, if the spikes we are going to put,
					# is around another already put on the map, we make it invalid
					var spikesContainer = get_tree().get_root().get_node("Main/SpikeContainer")
					for spikes in spikesContainer.get_children():
						# 50 pixels of distance between towers is enough 
						if copySpike.global_position.distance_to(spikes.global_position) < 50:
							valid = false
							break
				# to make it visual to the player, we would change the color
				# if a place is valid or not
				if valid:
					copySpike.modulate = Color(0, 1, 0, 1)
				else:
					copySpike.modulate = Color(1, 0, 0, 1)
				
				validTile = true if valid else false

		# trow the spike in the map
		elif event is InputEventMouseButton and event.button_mask == 0:
			var copySpike = get_tree().root.get_node_or_null("copySpike")
			if copySpike:
				#if is not inside the tileMap or in  a valid tile, then it does
				#not let put on the map
				if event.global_position.x >= 1024 or validTile == false: 
					copySpike.queue_free()
				else:
					# is if valid, we put the spikes in the map
					var path = get_tree().get_root().get_node("Main/SpikeContainer")
					copySpike.reparent(path)
					copySpike.global_position = copySpike.get_global_mouse_position()
					# the range is hide for visual purposes
					copySpike.get_node("AreaActive").hide()
					# we start again the functionality of the tower
					copySpike.process_mode = Node.PROCESS_MODE_INHERIT
					copySpike.name = "Spike"
					# we put the normal colors and rest the cost of the spikes
					copySpike.modulate = Color(1, 1, 1, 1)
					GameValues.gold -= GameValues.spikeCost
		else:
			# if there is not enough gold, we make it impossible to grab it
			var copySpike = get_tree().root.get_node_or_null("copySpike")
			if copySpike:
				copySpike.queue_free()
