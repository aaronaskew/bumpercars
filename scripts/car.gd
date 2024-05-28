extends RigidBody2D

@export var speed = 2500.0

@export var charging_rate = 50.0
@export var energy_use_rate = 40.0
@export var max_energy = 100.0
@export var energy = 0.0
@export var energy_sources_connected = 0
@export var is_grounded = false

@onready var ground_ray: RayCast2D = $GroundRayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
	%EnergyBar.max_value = max_energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if energy_sources_connected > 0:
		energy += charging_rate * delta
		energy = clampf(energy, 0, max_energy)
		%Sparks.emitting = true
	else:
		%Sparks.emitting = false
		
	%EnergyBar.value = energy
		
	print("energy: " + str(energy))

func _physics_process(delta):
	
	# check if grounded
	var ground_ray_collider = ground_ray.get_collider()
	var ground_ray_rid = ground_ray.get_collider_rid()
	is_grounded = ground_ray_collider && ground_ray_rid && _is_grounded(ground_ray_collider, ground_ray_rid)
	print("is_grounded: " +str(is_grounded))

	
	var force:Vector2 = Vector2.ZERO
	
	if energy > 0:
		force.x = Input.get_axis("left", "right") * speed
		apply_force(force)
	
	if force.length() > 0:
		energy -= energy_use_rate * delta




func _on_hook_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		_process_hook_tilemap_collision(body, body_rid, true)


func _on_hook_body_shape_exited(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		_process_hook_tilemap_collision(body, body_rid, false)
		
func _process_hook_tilemap_collision(body:TileMap, body_rid:RID, entered):
	var current_tilemap = body
	var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
	var tile_data = current_tilemap.get_cell_tile_data(0,collided_tile_coords)
	var is_energizing = tile_data.get_custom_data("energizing")
	if is_energizing:
		if entered:
			energy_sources_connected += 1
		else:
			energy_sources_connected -= 1
	
func _is_grounded(tile_map: TileMap, tile_rid:RID) -> bool:
	var collided_tile_coords = tile_map.get_coords_for_body_rid(tile_rid)
	var tile_data = tile_map.get_cell_tile_data(0,collided_tile_coords)
	var is_ground_tile = tile_data.get_custom_data("is_ground")
	
	return is_ground_tile
		


