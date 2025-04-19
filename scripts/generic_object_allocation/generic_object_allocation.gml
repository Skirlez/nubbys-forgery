global.items_allocated = 0
global.allocated_item_object_array = [];
function allocate_object_for_item(item) {
	var num = global.items_allocated
	global.items_allocated++;
	
	global.allocated_item_object_array[num] = item;
	return agi($"obj_generic_item{num}");
}
function get_allocated_item(num) {
	return global.allocated_item_object_array[num]
}
function free_all_allocated_items() {
	global.items_allocated = 0
	global.allocated_item_object_array = [];
}