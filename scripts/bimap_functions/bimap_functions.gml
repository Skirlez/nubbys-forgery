/**
Bisexual Map
*/
enum bimap_indices {
	left_to_right,
	right_to_left,
}

function bimap_create() {
	// That's right. It's two ds_maps in a trench coat
	return [ds_map_create(), ds_map_create()] 
}

function bimap_get_left(bimap, right) {
	return ds_map_find_value(bimap[bimap_indices.right_to_left], right)	
}
function bimap_get_right(bimap, left) {
	return ds_map_find_value(bimap[bimap_indices.left_to_right], left)	
}

function bimap_set(bimap, left, right) {
	ds_map_set(bimap[bimap_indices.left_to_right], left, right)
	ds_map_set(bimap[bimap_indices.right_to_left], right, left)
}

function bimap_delete_left(bimap, left) {
	var right = ds_map_find_value(bimap[bimap_indices.left_to_right], left)
	bimap_delete(bimap, left, right)
}
function bimap_delete_right(bimap, right) {
	var left = ds_map_find_value(bimap[bimap_indices.right_to_left], right)
	bimap_delete(bimap, left, right)
}
function bimap_delete(bimap, left, right) {
	ds_map_delete(bimap[bimap_indices.left_to_right], left)
	ds_map_delete(bimap[bimap_indices.right_to_left], right)
}

function bimap_clear(bimap) {
	ds_map_clear(bimap[bimap_indices.left_to_right])
	ds_map_clear(bimap[bimap_indices.right_to_left])	
}
function bimap_destroy(bimap) {
	ds_map_destroy(bimap[bimap_indices.left_to_right])
	ds_map_destroy(bimap[bimap_indices.right_to_left])	
}

function bimap_lefts_array(bimap) {
	return ds_map_keys_to_array(bimap[bimap_indices.left_to_right])	
}
function bimap_rights_array(bimap) {
	return ds_map_keys_to_array(bimap[bimap_indices.right_to_left])	
}

function bimap_left_exists(bimap, left) {
	return ds_map_exists(bimap[bimap_indices.left_to_right], left)	
}
function bimap_right_exists(bimap, right) {
	return ds_map_exists(bimap[bimap_indices.right_to_left], right)	
}