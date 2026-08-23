extends Node2D

var current_unit
var astar_grid : AStarGrid2D

@onready var tilemap = $ground_1 
@onready var warrior = $warrior
@onready var lancer = $lancer
@onready var highlight_layer = $highlight
@onready var change_trigger = $Control/Button

func _ready():
	warrior.play("idle")
	lancer.play("idle")
	
	change_trigger.end_turn.connect(change_unit)
	
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


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed :
		
		var mouse_pos = get_global_mouse_position()
		var target_grid_pos = tilemap.local_to_map(mouse_pos)
		var current_unit_grid_pos = tilemap.local_to_map(current_unit.global_position)
		
		var enemies = lancer if current_unit == warrior else warrior
		var enemies_pos = tilemap.local_to_map(enemies.global_position)
		
		if target_grid_pos == current_unit_grid_pos:
			return
		
		astar_grid.set_point_solid(current_unit_grid_pos, false)
		astar_grid.set_point_solid(enemies_pos, false)
		
		var path = astar_grid.get_id_path(current_unit_grid_pos, target_grid_pos)
		
		if path.is_empty() and target_grid_pos != enemies_pos:
			print("no ground detected!")
			astar_grid.set_point_solid(current_unit_grid_pos, true) 
			
		else:
			path.pop_front()
			var tween = get_tree().create_tween()
			
			if target_grid_pos.x < current_unit_grid_pos.x:
				current_unit.flip_h = true
			elif target_grid_pos.x > current_unit_grid_pos.x:
				current_unit.flip_h = false
			
			current_unit.play("run")
			
			if target_grid_pos == enemies_pos:
				path.pop_back()
				
			for point in path:
				var target_pixel_pos = tilemap.map_to_local(point)
				tween.tween_property(current_unit, "global_position", target_pixel_pos, 0.4)
				
			await tween.finished
			
			current_unit.play("idle")
			if target_grid_pos == enemies_pos:
				current_unit.play("attack")
			astar_grid.set_point_solid(enemies_pos, true)
			astar_grid.set_point_solid(target_grid_pos, true)
			
			

func change_unit():
	
	if current_unit == warrior:
		current_unit = lancer
	else :
		current_unit = warrior

func move_unit():
	pass
	
