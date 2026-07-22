extends Node2D

var current_unit
var astar_grid : AStarGrid2D

var ismoving = false
@onready var tilemap = $ground_1 
@onready var warrior = $warrior
@onready var lancer = $lancer
@onready var highlight_layer = $highlight

func _ready():
	warrior.play("idle")
	lancer.play("idle")
	
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tilemap.get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = Vector2(64, 64)
	astar_grid.update()
	

	for x in range(astar_grid.region.position.x, astar_grid.region.end.x):
		for y in range(astar_grid.region.position.y, astar_grid.region.end.y):
			var grid_pos = Vector2i(x, y)
			var tile_id = tilemap.get_cell_source_id(grid_pos) 
		
			if tile_id == -1:
				astar_grid.set_point_solid(grid_pos, true)
			
	var w_pos = tilemap.local_to_map(warrior.global_position)
	var l_pos = tilemap.local_to_map(lancer.global_position)
	
	astar_grid.set_point_solid(w_pos, true)
	astar_grid.set_point_solid(l_pos, true)
	
	current_unit = warrior
	draw_movement_range()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed :
		
		var mouse_pos = get_global_mouse_position()
		var target_grid_pos = tilemap.local_to_map(mouse_pos)
		var current_unit_grid_pos = tilemap.local_to_map(current_unit.global_position)
		
		var enemies = lancer if current_unit == warrior else warrior
		var enemies_pos = tilemap.local_to_map(enemies.global_position)
		
		# CEK ATK
		if target_grid_pos == enemies_pos :
			var distance = abs(current_unit_grid_pos.x - target_grid_pos.x) + abs(current_unit_grid_pos.y - target_grid_pos.y)
			
			if distance == 1 :
				if target_grid_pos.x > current_unit_grid_pos.x :
					current_unit.flip_h = false
				elif target_grid_pos.x < current_unit_grid_pos.x :
					current_unit.flip_h = true
				
				current_unit.play("attack")
				await current_unit.animation_finished
				current_unit.play("idle")
				
				if current_unit == warrior:
					current_unit = lancer
				else :
					current_unit = warrior
					
				draw_movement_range()
				
			else:
				print("Kejauhan! Gagal nyerang.")
				
			return 
			
		# MOVE
		
		if target_grid_pos == current_unit_grid_pos:
			return
			
		astar_grid.set_point_solid(current_unit_grid_pos, false)
		var path = astar_grid.get_id_path(current_unit_grid_pos, target_grid_pos)
		
		if path.is_empty():
			print("Tidak bisa lewat sana!")
			astar_grid.set_point_solid(current_unit_grid_pos, true) 
			
		elif (path.size() - 1) > current_unit.mov_range:
			print("Kejauhan!")
			astar_grid.set_point_solid(current_unit_grid_pos, true) 
		else:
			path.pop_front()
			var tween = get_tree().create_tween()
			
			if target_grid_pos.x < current_unit_grid_pos.x:
				current_unit.flip_h = true
			elif target_grid_pos.x > current_unit_grid_pos.x:
				current_unit.flip_h = false
			
			current_unit.play("run") 
			
			for point in path:
				var target_pixel_pos = tilemap.map_to_local(point)
				tween.tween_property(current_unit, "global_position", target_pixel_pos, 0.4)
				
			await tween.finished
			
			astar_grid.set_point_solid(target_grid_pos, true)
			current_unit.play("idle")
			
			if current_unit == warrior:
				current_unit = lancer
			else :
				current_unit = warrior
				
			draw_movement_range()
			
func draw_movement_range():
	highlight_layer.clear()
	var start_pos = tilemap.local_to_map(current_unit.global_position)
	var range_limit = current_unit.mov_range
	
	astar_grid.set_point_solid(start_pos, false)
	for x in range(-range_limit, range_limit + 1):
		for y in range(-range_limit, range_limit + 1):
			var target_pos = start_pos + Vector2i(x,y)
			var path = astar_grid.get_id_path(start_pos, target_pos)
			if not path.is_empty() and (path.size() - 1) <= range_limit:
				highlight_layer.set_cell(target_pos, 1, Vector2i(0,0))
	
	astar_grid.set_point_solid(start_pos, true)
	
