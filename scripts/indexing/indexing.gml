global.indexed_resources = array_create_ext(mod_resources.size, function () { 
	return bimap_create();
})

function clear_index_assignments(type) {
	bimap_clear(global.indexed_resources[type]);
	
}
function assign_index_to_resource(type, resource, index) {
	bimap_set(global.indexed_resources[type], index, resource)
}

function get_index_of_resource(type, resource) {
	return bimap_get_left(global.indexed_resources[type], resource)
}

function get_resource_by_index(type, index) {
	return bimap_get_right(global.indexed_resources[type], index)
}