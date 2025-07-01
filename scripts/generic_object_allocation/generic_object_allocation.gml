global.allocated_objects = array_create_ext(mod_resources.size, function () { 
	return [] 
})
function allocate_object(type, resource) {
	var arr = global.allocated_objects[type]
	array_push(arr, resource);
	return agi($"obj_generic_{global.resource_names[type]}{array_length(arr) - 1}");
}
function free_all_allocated_objects(type) {
	global.allocated_objects[type] = []
}
	function get_resource_allocated_to_object(type, num) {
	return global.allocated_objects[type][num]
}


