extends Node2D

var astar_grid : AStarGrid2D
@onready var tilemap = $ground_1 
@onready var warrior = $warrior
@onready var lancer = $lancer
@onready var highlight_layer = $highlight

func _ready():
	warrior.play("warrior_idle")
	lancer.play("idle")
	
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tilemap.get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = Vector2(64, 64) 
	astar_grid.update()
	
	draw_movement_range()

	for x in range(astar_grid.region.position.x, astar_grid.region.end.x):
		for y in range(astar_grid.region.position.y, astar_grid.region.end.y):
			var grid_pos = Vector2i(x, y)
			var tile_id = tilemap.get_cell_source_id(grid_pos) 
		
			if tile_id == -1:
				astar_grid.set_point_solid(grid_pos, true)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var mouse_pos = get_global_mouse_position()
		var target_grid_pos = tilemap.local_to_map(mouse_pos)
		var warrior_grid_pos = tilemap.local_to_map(warrior.global_position)
		
		var path = astar_grid.get_id_path(warrior_grid_pos, target_grid_pos)
		if path.is_empty() and path :
			print("no tiles")
		
		elif (path.size() - 1) > warrior.mov_range:
			print(path.size())
		else:
			path.pop_front()
			var tween = get_tree().create_tween()
			warrior.play("warrior_run")
			
			for point in path:
				var target_pixel_pos = tilemap.map_to_local(point)
				tween.tween_property(warrior, "global_position", target_pixel_pos, 0.4)
			await tween.finished
			warrior.play("warrior_idle")
			draw_movement_range()
			
func draw_movement_range():
	highlight_layer.clear()
	var start_pos = tilemap.local_to_map(warrior.global_position)
	var range_limit = warrior.mov_range
	
	print_debug(start_pos)
	for x in range(-range_limit, range_limit + 1):
		for y in range(-range_limit, range_limit + 1):
			var target_pos = start_pos + Vector2i(x,y)
			var path = astar_grid.get_id_path(start_pos, target_pos)
			print(target_pos)
			if not path.is_empty() and (path.size() - 1) <= range_limit:
				highlight_layer.set_cell(target_pos, 1, Vector2i(0,0))
	
