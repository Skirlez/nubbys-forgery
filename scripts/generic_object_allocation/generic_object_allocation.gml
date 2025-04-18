// all ds_maps freed in obj_modloader clean up

global.item_objects_allocated = ds_map_create();
function allocate_object_for_item(item) {
	var num = 0;
	while ds_map_exists(global.item_objects_allocated, num)
		num++;
	ds_map_add(global.item_objects_allocated, num, item)
	return agi($"obj_generic_item{num}");
}
function get_allocated_item(num) {
	return ds_map_find_value(global.item_objects_allocated, num);
}
function free_allocated_item(num) {
	ds_map_delete(global.item_objects_allocated, num)	
}