
enum allocatable_objects {
	item,
	perk,
	supervisor,
}
global.allocatable_object_names = ["item", "perk", "supervisor"]

global.allocated_objects = ds_map_create();
function allocate_object(type, resource) {
	if !ds_map_exists(global.allocated_objects, type)
		ds_map_add(global.allocated_objects, type, [])
	var arr = ds_map_find_value(global.allocated_objects, type);
	array_push(arr, resource);
	return agi($"obj_generic_{global.allocatable_object_names[type]}{array_length(arr) - 1}");
}
function free_all_allocated_objects(type) {
	ds_map_set(global.allocated_objects, type, [])
}
function get_allocated_object(type, num) {
	return ds_map_find_value(global.allocated_objects, type)[num]
}

