global.index_registry = registry_create();

function clear_index_assignments(type) {
	bimap_clear(global.index_registry[type]);
}
function assign_index_to_resource(type, resource, index) {
	bimap_set(global.index_registry[type], index, resource)
}